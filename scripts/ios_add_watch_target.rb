# Adds the AlrtWatch watchOS app to frontend/ios/Runner.xcodeproj and embeds
# it in the iPhone app (Runner). Idempotent. Needs the xcodeproj gem.
require 'xcodeproj'

PROJECT = 'frontend/ios/Runner.xcodeproj'
proj = Xcodeproj::Project.open(PROJECT)
runner = proj.targets.find { |t| t.name == 'Runner' } or abort('Runner target not found')

if proj.targets.any? { |t| t.name == 'AlrtWatch' }
  puts 'AlrtWatch target already present, nothing to do.'
  exit 0
end

watch = proj.new_target(:application, 'AlrtWatch', :watchos, '9.0')

group = proj.main_group.new_group('AlrtWatch', 'AlrtWatch')
refs = %w[AlrtWatchApp.swift GlanceModel.swift GlanceView.swift].map { |f| group.new_file(f) }
watch.add_file_references(refs)
group.new_file('Info.plist')
xcconfig = group.new_file('Watch.xcconfig')

runner_ids = {}
runner.build_configurations.each { |c| runner_ids[c.name] = c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] }

watch.build_configurations.each do |c|
  parent = (runner_ids[c.name] || 'com.safetyalrt.alrt').to_s
  dev = parent.include?('.dev')
  c.base_configuration_reference = xcconfig
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = "#{parent}.watchkitapp"
  s['WK_COMPANION_BUNDLE_ID'] = parent
  s['INFOPLIST_FILE'] = 'AlrtWatch/Info.plist'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['DEVELOPMENT_TEAM'] = 'JR89M7CYPR'
  s['SWIFT_VERSION'] = '5.0'
  s['SDKROOT'] = 'watchos'
  s['TARGETED_DEVICE_FAMILY'] = '4'
  s['WATCHOS_DEPLOYMENT_TARGET'] = '9.0'
  s['SKIP_INSTALL'] = 'YES'
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['CODE_SIGN_STYLE'] = 'Manual'
  s['PROVISIONING_PROFILE_SPECIFIER'] = dev ? 'match AppStore com.safetyalrt.alrt.dev.watchkitapp' : 'match AppStore com.safetyalrt.alrt.watchkitapp'
  s['CODE_SIGN_IDENTITY'] = 'iPhone Distribution' if c.name.start_with?('Release')
end

# NOT embedded in Runner yet, on purpose. `flutter build ios` / `flutter build
# ipa` pass `-sdk iphoneos|iphonesimulator` to xcodebuild, which forces every
# dependent target onto the iOS SDK, so an embedded watchOS app fails to
# compile ("'Scene' is only available in iOS 14.0"). Embedding needs the
# release workflow to archive with `xcodebuild archive -destination
# generic/platform=iOS` instead, plus a signing profile for the watch app
# (see docs/WIDGETS_AND_WATCHES.md).

proj.save
puts "Added AlrtWatch (not embedded in Runner)."
