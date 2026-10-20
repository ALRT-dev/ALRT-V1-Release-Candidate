#!/usr/bin/env ruby
# Adds the AlrtWidget (iOS WidgetKit) and AlrtWatch (watchOS) extension targets
# to Runner.xcodeproj without opening Xcode.
# Run from frontend/ios/:  bundle exec ruby add_extension_targets.rb
# Re-running is safe: checks for existing targets before adding.

require 'xcodeproj'

PROJECT_PATH = 'Runner.xcodeproj'
TEAM_ID      = 'JR89M7CYPR'

project = Xcodeproj::Project.open(PROJECT_PATH)
runner  = project.targets.find { |t| t.name == 'Runner' }
abort('Runner target not found') unless runner

# ─────────────────────────────────────────────────────────────────────────────
# Helper: set common build settings on both Debug and Release configs
# ─────────────────────────────────────────────────────────────────────────────
def set_build_settings(target, settings)
  target.build_configurations.each do |cfg|
    settings.each { |k, v| cfg.build_settings[k] = v }
  end
end

# ─────────────────────────────────────────────────────────────────────────────
# 1. iOS WidgetKit extension — AlrtWidget
# ─────────────────────────────────────────────────────────────────────────────
if project.targets.any? { |t| t.name == 'AlrtWidget' }
  puts 'AlrtWidget target already exists — skipping.'
else
  puts 'Adding AlrtWidget target…'

  widget = project.new_target(:app_extension, 'AlrtWidget', :ios, '16.0')

  set_build_settings(widget, {
    'PRODUCT_BUNDLE_IDENTIFIER'    => 'com.safetyalrt.alrt.dev.AlrtWidget',
    'PRODUCT_NAME'                 => 'AlrtWidget',
    'DEVELOPMENT_TEAM'             => TEAM_ID,
    'SWIFT_VERSION'                => '5.0',
    'INFOPLIST_FILE'               => 'AlrtWidget/Info.plist',
    'CODE_SIGN_ENTITLEMENTS'       => 'AlrtWidget/AlrtWidget-dev.entitlements',
    'SKIP_INSTALL'                 => 'YES',
    'MARKETING_VERSION'            => '$(FLUTTER_BUILD_NAME)',
    'CURRENT_PROJECT_VERSION'      => '$(FLUTTER_BUILD_NUMBER)',
    'TARGETED_DEVICE_FAMILY'       => '1,2',
    'LD_RUNPATH_SEARCH_PATHS'      => '$(inherited) @executable_path/../../Frameworks',
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
  })

  # Xcconfig per build config
  widget.build_configuration('Debug').build_settings['XCCONFIG_FILE'] = 'AlrtWidget/Widget.xcconfig' rescue nil
  widget.build_configuration('Release').build_settings['XCCONFIG_FILE'] = 'AlrtWidget/Widget.xcconfig' rescue nil

  # Source file group + build phase references
  widget_group = project.main_group.new_group('AlrtWidget', 'AlrtWidget')
  %w[AlrtWidgetBundle.swift AlrtAlertsWidget.swift AlrtFamilyWidget.swift].each do |f|
    ref = widget_group.new_file("AlrtWidget/#{f}")
    widget.source_build_phase.add_file_reference(ref)
  end
  widget_group.new_file('AlrtWidget/Info.plist')
  widget_group.new_file('AlrtWidget/AlrtWidget-dev.entitlements')
  widget_group.new_file('AlrtWidget/AlrtWidget.entitlements')
  widget_group.new_file('AlrtWidget/Widget.xcconfig')

  # WidgetKit + SwiftUI frameworks
  fwk_group = project.frameworks_group
  [
    ['WidgetKit',  'WidgetKit.framework'],
    ['SwiftUI',    'SwiftUI.framework'],
  ].each do |name, path|
    existing = fwk_group.files.find { |f| f.display_name == "#{name}.framework" }
    ref = existing || fwk_group.new_file("System/Library/Frameworks/#{path}")
    ref.source_tree = 'SDKROOT' unless existing
    widget.frameworks_build_phase.add_file_reference(ref, true)
  end

  # Embed the extension into Runner (Plug-ins subfolder = 13)
  embed = runner.new_copy_files_build_phase('Embed App Extensions')
  embed.dst_subfolder_spec = '13'
  embed_ref = embed.add_file_reference(widget.product_reference)
  embed_ref.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

  puts '  AlrtWidget added ✓'
end

# ─────────────────────────────────────────────────────────────────────────────
# 2. watchOS companion app — AlrtWatch
# ─────────────────────────────────────────────────────────────────────────────
if project.targets.any? { |t| t.name == 'AlrtWatch' }
  puts 'AlrtWatch target already exists — skipping.'
else
  puts 'Adding AlrtWatch target…'

  watch = project.new_target(:watch2_app, 'AlrtWatch', :watchos, '7.0')

  set_build_settings(watch, {
    'PRODUCT_BUNDLE_IDENTIFIER'    => 'com.safetyalrt.alrt.dev.watchkitapp',
    'PRODUCT_NAME'                 => 'AlrtWatch',
    'DEVELOPMENT_TEAM'             => TEAM_ID,
    'SWIFT_VERSION'                => '5.0',
    'INFOPLIST_FILE'               => 'AlrtWatch/Info.plist',
    'SKIP_INSTALL'                 => 'YES',
    'MARKETING_VERSION'            => '$(FLUTTER_BUILD_NAME)',
    'CURRENT_PROJECT_VERSION'      => '$(FLUTTER_BUILD_NUMBER)',
    'TARGETED_DEVICE_FAMILY'       => '4',
    'SDKROOT'                      => 'watchos',
    'WATCHOS_DEPLOYMENT_TARGET'    => '7.0',
    'LD_RUNPATH_SEARCH_PATHS'      => '$(inherited) @executable_path/Frameworks',
  })

  # Source file group
  watch_group = project.main_group.new_group('AlrtWatch', 'AlrtWatch')
  %w[AlrtWatchApp.swift GlanceModel.swift GlanceView.swift].each do |f|
    ref = watch_group.new_file("AlrtWatch/#{f}")
    watch.source_build_phase.add_file_reference(ref)
  end
  watch_group.new_file('AlrtWatch/Info.plist')
  watch_group.new_file('AlrtWatch/Watch.xcconfig')

  # WatchConnectivity + SwiftUI frameworks
  fwk_group = project.frameworks_group
  [
    ['WatchConnectivity', 'WatchConnectivity.framework'],
    ['SwiftUI',           'SwiftUI.framework'],
  ].each do |name, path|
    existing = fwk_group.files.find { |f| f.display_name == "#{name}.framework" }
    ref = existing || fwk_group.new_file("System/Library/Frameworks/#{path}")
    ref.source_tree = 'SDKROOT' unless existing
    watch.frameworks_build_phase.add_file_reference(ref, true)
  end

  # Embed the watch app into Runner (Watch content subfolder = 16)
  embed_watch = runner.new_copy_files_build_phase('Embed Watch Content')
  embed_watch.dst_subfolder_spec = '16'
  embed_ref = embed_watch.add_file_reference(watch.product_reference)
  embed_ref.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

  puts '  AlrtWatch added ✓'
end

project.save
puts "project.pbxproj saved ✓  (#{project.targets.map(&:name).join(', ')})"
