#!/usr/bin/env ruby
# Adds the ALRT Apple Watch companion target (AlrtWatch) to Runner.xcodeproj
# and embeds it in the iPhone app. Idempotent: running it again changes
# nothing. Written so the Xcode project change can be made and reviewed
# without a Mac; opening the project in Xcode afterwards shows the same
# target Xcode's own "Watch App for Existing iOS App" template would create.
#
#   gem install xcodeproj && ruby scripts/add_watch_target.rb
require "xcodeproj"

PROJECT = File.expand_path("../Runner.xcodeproj", __dir__)
TEAM = "JR89M7CYPR"
WATCHOS = "10.0"

project = Xcodeproj::Project.open(PROJECT)
runner = project.targets.find { |t| t.name == "Runner" } or abort("Runner target missing")
# Project level (seen by Runner AND AlrtWatch): the iPhone app's bundle id
# per configuration. AlrtWatch/Info.plist names its companion with it, and
# Flutter's build tool resolves that value against RUNNER's settings to
# detect the watch app. Without it Flutter builds everything with the
# iPhone SDK and the watch target cannot build.
project.build_configurations.each do |config|
  host = config.name.end_with?("-dev") ? "com.safetyalrt.alrt.dev" : "com.safetyalrt.alrt"
  config.build_settings["ALRT_COMPANION_BUNDLE_ID"] = host
end

def apply_watch_settings(watch)
  xcconfig = watch.project.files.find { |f| f.path == "AlrtWatch.xcconfig" } or abort("AlrtWatch.xcconfig reference missing")
  watch.build_configurations.each do |config|
  dev = config.name.end_with?("-dev")
  host = dev ? "com.safetyalrt.alrt.dev" : "com.safetyalrt.alrt"
  config.base_configuration_reference = xcconfig
  s = config.build_settings
  s["PRODUCT_NAME"] = "$(TARGET_NAME)"
  s["PRODUCT_BUNDLE_IDENTIFIER"] = "#{host}.watchkitapp"
  s["ALRT_COMPANION_BUNDLE_ID"] = host
  s["INFOPLIST_FILE"] = "AlrtWatch/Info.plist"
  s["GENERATE_INFOPLIST_FILE"] = "YES"
  s["INFOPLIST_KEY_CFBundleDisplayName"] = "ALRT"
  s["INFOPLIST_KEY_WKCompanionAppBundleIdentifier"] = "$(ALRT_COMPANION_BUNDLE_ID)"
  s["INFOPLIST_KEY_UISupportedInterfaceOrientations"] = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown"
  s["ASSETCATALOG_COMPILER_APPICON_NAME"] = dev ? "AppIcon-dev" : "AppIcon-prod"
  s["SDKROOT"] = "watchos"
  # The project level says SUPPORTED_PLATFORMS = iphoneos; without this the
  # watch target inherits it and Xcode builds it for iPhone.
  s["SUPPORTED_PLATFORMS"] = "watchos watchsimulator"
  s["WATCHOS_DEPLOYMENT_TARGET"] = WATCHOS
  s["TARGETED_DEVICE_FAMILY"] = "4"
  s["SWIFT_VERSION"] = "5.0"
  s["SKIP_INSTALL"] = "YES"
  s["ENABLE_PREVIEWS"] = "YES"
  s["CODE_SIGN_STYLE"] = "Automatic"
  s["DEVELOPMENT_TEAM"] = TEAM
  s["CODE_SIGN_IDENTITY"] = "Apple Development"
  s["LD_RUNPATH_SEARCH_PATHS"] = ["$(inherited)", "@executable_path/Frameworks"]
  s["SWIFT_EMIT_LOC_STRINGS"] = "YES"
  s.delete("IPHONEOS_DEPLOYMENT_TARGET")
  s.delete("ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME")
  end
end


existing = project.targets.find { |t| t.name == "AlrtWatch" }
if existing
  apply_watch_settings(existing)
  project.save
  puts "AlrtWatch already present; settings re-applied."
  exit 0
end

watch = project.new_target(:application, "AlrtWatch", :watchos, WATCHOS)
# Same configurations as Runner (Debug/Release/Profile x dev/prod) and no
# others, so `flutter build --flavor dev` builds the watch app as Release-dev.
runner_configs = runner.build_configurations.map(&:name)
watch.build_configuration_list.build_configurations.to_a.each do |config|
  config.remove_from_project unless runner_configs.include?(config.name)
end
missing = runner_configs - watch.build_configurations.map(&:name)
abort("AlrtWatch is missing configurations: #{missing.join(', ')}") unless missing.empty?
watch.build_configuration_list.default_configuration_name =
  runner.build_configuration_list.default_configuration_name

group = project.main_group.find_subpath("AlrtWatch", true)
group.set_source_tree("<group>")
group.set_path("AlrtWatch")
%w[AlrtWatchApp.swift WatchModels.swift WatchStore.swift Views.swift SosScreen.swift].each do |file|
  watch.source_build_phase.add_file_reference(group.new_reference(file))
end
watch.resources_build_phase.add_file_reference(group.new_reference("Assets.xcassets"))
group.new_reference("Info.plist")
xcconfig = group.new_reference("AlrtWatch.xcconfig")

apply_watch_settings(watch)

# Embed the watch app in the iPhone app (Xcode's "Embed Watch Content").
# Placed straight after "Embed Frameworks" and before Flutter's
# "Thin Binary" script, the order that avoids Xcode's "Cycle inside Runner".
embed = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
embed.name = "Embed Watch Content"
embed.dst_subfolder_spec = "16"
embed.dst_path = "$(CONTENTS_FOLDER_PATH)/Watch"
build_file = embed.add_file_reference(watch.product_reference, true)
build_file.settings = { "ATTRIBUTES" => ["RemoveHeadersOnCopy"] }
anchor = runner.build_phases.index { |p| p.respond_to?(:name) && p.name == "Embed Frameworks" }
runner.build_phases.insert(anchor ? anchor + 1 : runner.build_phases.length, embed)
runner.add_dependency(watch)

attrs = project.root_object.attributes["TargetAttributes"] ||= {}
attrs[watch.uuid] = { "CreatedOnToolsVersion" => "26.0" }

project.save
puts "Added AlrtWatch (watchOS #{WATCHOS}) and embedded it in Runner."
