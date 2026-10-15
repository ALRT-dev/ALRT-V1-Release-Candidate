# Attach the existing WidgetKit sources through Xcodeproj's object model.
# Safe to rerun locally or in CI; does not contact Apple or alter Runner signing.
require 'xcodeproj'

module AlrtWidgetProject
  def self.configure(path)
    project = Xcodeproj::Project.open(path)
    runner = project.targets.find { |target| target.name == 'Runner' }
    raise 'Runner target is missing' unless runner

    generated = project.files.find { |file| File.basename(file.path.to_s) == 'Generated.xcconfig' }
    raise 'Flutter Generated.xcconfig reference is missing' unless generated

    widget = project.targets.find { |target| target.name == 'AlrtWidget' }
    widget ||= project.new_target(:app_extension, 'AlrtWidget', :ios, '15.6', nil, :swift)
    group = project.main_group.groups.find { |item| item.path == 'AlrtWidget' }
    group ||= project.main_group.new_group('AlrtWidget', 'AlrtWidget')

    %w[AlrtAlertsWidget.swift AlrtFamilyWidget.swift AlrtWidgetBundle.swift].each do |filename|
      reference = group.files.find { |file| file.path == filename } || group.new_file(filename)
      widget.add_file_references([reference]) unless widget.source_build_phase.files_references.include?(reference)
    end
    %w[Info.plist AlrtWidget.entitlements AlrtWidget-dev.entitlements].each do |filename|
      group.new_file(filename) unless group.files.any? { |file| file.path == filename }
    end
    # SDKROOT resolves against the selected device/simulator SDK. Xcodeproj's
    # add_system_framework otherwise bakes its own default SDK version into
    # the path, which differs between gem versions and duplicates references.
    %w[Foundation WidgetKit SwiftUI].each do |framework|
      filename = "#{framework}.framework"
      reference = widget.frameworks_build_phase.files_references.find { |file| File.basename(file.path) == filename }
      reference ||= project.frameworks_group.new_file("System/Library/Frameworks/#{filename}", :sdk_root)
      reference.path = "System/Library/Frameworks/#{filename}"
      reference.source_tree = 'SDKROOT'
      widget.frameworks_build_phase.add_file_reference(reference, true)
    end

    names = project.build_configurations.map(&:name)
    widget.build_configurations.to_a.each do |configuration|
      configuration.remove_from_project unless names.include?(configuration.name)
    end
    project.build_configurations.each do |configuration|
      widget.add_build_configuration(configuration.name, configuration.type)
    end
    widget.build_configuration_list.default_configuration_name = runner.build_configuration_list.default_configuration_name

    widget.build_configurations.each do |configuration|
      dev = configuration.name.end_with?('-dev')
      configuration.base_configuration_reference = generated
      configuration.build_settings.merge!(
        'APPLICATION_EXTENSION_API_ONLY' => 'YES',
        'CLANG_ENABLE_MODULES' => 'YES',
        'CODE_SIGN_ENTITLEMENTS' => dev ? 'AlrtWidget/AlrtWidget-dev.entitlements' : 'AlrtWidget/AlrtWidget.entitlements',
        'CODE_SIGN_STYLE' => 'Automatic',
        'CURRENT_PROJECT_VERSION' => '$(FLUTTER_BUILD_NUMBER)',
        'DEVELOPMENT_TEAM' => 'JR89M7CYPR',
        'GENERATE_INFOPLIST_FILE' => 'NO',
        'INFOPLIST_FILE' => 'AlrtWidget/Info.plist',
        'IPHONEOS_DEPLOYMENT_TARGET' => '15.6',
        'LD_RUNPATH_SEARCH_PATHS' => ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks'],
        'MARKETING_VERSION' => '$(FLUTTER_BUILD_NAME)',
        'PRODUCT_BUNDLE_IDENTIFIER' => dev ? 'com.safetyalrt.alrt.dev.AlrtWidget' : 'com.safetyalrt.alrt.AlrtWidget',
        'PRODUCT_NAME' => '$(TARGET_NAME)',
        'SKIP_INSTALL' => 'YES',
        'SWIFT_VERSION' => '5.0',
        'TARGETED_DEVICE_FAMILY' => '1,2'
      )
    end

    runner.add_dependency(widget) unless runner.dependencies.any? { |dependency| dependency.target == widget }
    phase = runner.copy_files_build_phases.find { |item| item.name == 'Embed App Extensions' }
    phase ||= runner.new_copy_files_build_phase('Embed App Extensions')
    phase.dst_subfolder_spec = '13' # PlugIns inside Runner.app
    phase.dst_path = ''
    unless phase.files_references.include?(widget.product_reference)
      phase.add_file_reference(widget.product_reference).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
    end
    # Flutter's thinning script reads the completed app; embedding afterwards
    # can create an Xcode dependency cycle.
    runner.build_phases.delete(phase)
    thinning = runner.build_phases.find { |item| item.respond_to?(:name) && item.name == 'Thin Binary' }
    runner.build_phases.insert(thinning ? runner.build_phases.index(thinning) : runner.build_phases.length, phase)

    attributes = project.root_object.attributes['TargetAttributes'] ||= {}
    attributes[widget.uuid] ||= {}
    attributes[widget.uuid]['SystemCapabilities'] = { 'com.apple.ApplicationGroups.iOS' => { 'enabled' => 1 } }
    project.save
  end
end

if $PROGRAM_NAME == __FILE__
  AlrtWidgetProject.configure(ARGV.fetch(0, File.expand_path('../Runner.xcodeproj', __dir__)))
  puts 'AlrtWidget target and embedding are configured.'
end
