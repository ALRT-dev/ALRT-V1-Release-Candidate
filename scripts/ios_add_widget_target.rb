# Adds the AlrtWidget WidgetKit extension to frontend/ios/Runner.xcodeproj and
# embeds it in Runner. Idempotent. Run from the repository root with the
# xcodeproj gem (it ships with fastlane and CocoaPods).
require 'xcodeproj'

PROJECT = 'frontend/ios/Runner.xcodeproj'
proj = Xcodeproj::Project.open(PROJECT)
runner = proj.targets.find { |t| t.name == 'Runner' } or abort('Runner target not found')

if proj.targets.any? { |t| t.name == 'AlrtWidget' }
  puts 'AlrtWidget target already present, nothing to do.'
  exit 0
end

ext = proj.new_target(:app_extension, 'AlrtWidget', :ios, '16.0')

group = proj.main_group.new_group('AlrtWidget', 'AlrtWidget')
sources = %w[AlrtAlertsWidget.swift AlrtFamilyWidget.swift AlrtWidgetBundle.swift]
refs = sources.map { |f| group.new_file(f) }
ext.add_file_references(refs)
group.new_file('Info.plist')
group.new_file('AlrtWidget.entitlements')
group.new_file('AlrtWidget-dev.entitlements')
xcconfig = group.new_file('Widget.xcconfig')

runner_ids = {}
runner.build_configurations.each do |c|
  runner_ids[c.name] = c.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
end

ext.build_configurations.each do |c|
  parent = runner_ids[c.name] || 'com.safetyalrt.alrt'
  parent = parent.to_s
  bundle = "#{parent}.AlrtWidget"
  dev = parent.include?('.dev')
  c.base_configuration_reference = xcconfig
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = bundle
  s['INFOPLIST_FILE'] = 'AlrtWidget/Info.plist'
  s['CODE_SIGN_ENTITLEMENTS'] = dev ? 'AlrtWidget/AlrtWidget-dev.entitlements' : 'AlrtWidget/AlrtWidget.entitlements'
  s['DEVELOPMENT_TEAM'] = 'JR89M7CYPR'
  s['SWIFT_VERSION'] = '5.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  s['SKIP_INSTALL'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CODE_SIGN_STYLE'] = 'Manual'
  s['PROVISIONING_PROFILE_SPECIFIER'] = dev ? 'match AppStore com.safetyalrt.alrt.dev.AlrtWidget' : 'match AppStore com.safetyalrt.alrt.AlrtWidget'
  s['CODE_SIGN_IDENTITY'] = 'iPhone Distribution' if c.name.start_with?('Release')
end

runner.add_dependency(ext)
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
bf = embed.add_file_reference(ext.product_reference, true)
bf.settings = { 'ATTRIBUTES' => %w[RemoveHeadersOnCopy] }

# Put the embed phase before Flutter's "Thin Binary" script to avoid a build cycle.
phases = runner.build_phases
phases.delete(embed)
idx = phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' } || phases.length
phases.insert(idx, embed)

proj.save
puts "Added AlrtWidget; Runner phases now: #{runner.build_phases.map { |p| p.respond_to?(:name) && p.name ? p.name : p.isa }.join(' | ')}"
