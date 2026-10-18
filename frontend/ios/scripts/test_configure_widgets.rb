require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'xcodeproj'
require_relative 'configure_widgets'

class ConfigureWidgetsTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir('alrt-widget-test')
    original = File.expand_path('../Runner.xcodeproj', __dir__)
    FileUtils.cp_r(original, @directory)
    @path = File.join(@directory, 'Runner.xcodeproj')
    @before = Xcodeproj::Project.open(@path)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def configure
    AlrtWidgetProject.configure(@path)
    Xcodeproj::Project.open(@path)
  end

  def test_sources_are_compiled_and_extension_is_embedded_before_flutter_thinning
    project = configure
    widget = project.targets.find { |target| target.name == 'AlrtWidget' }
    runner = project.targets.find { |target| target.name == 'Runner' }
    assert_equal 'com.apple.product-type.app-extension', widget.product_type
    assert_equal %w[AlrtAlertsWidget.swift AlrtFamilyWidget.swift AlrtWidgetBundle.swift],
                 widget.source_build_phase.files_references.map(&:path).sort
    assert runner.dependencies.any? { |dependency| dependency.target == widget }
    phase = runner.copy_files_build_phases.find { |item| item.name == 'Embed App Extensions' }
    assert_equal '13', phase.dst_subfolder_spec
    assert_equal [widget.product_reference], phase.files_references
    frameworks = widget.frameworks_build_phase.files_references
    assert_equal %w[Foundation.framework SwiftUI.framework WidgetKit.framework], frameworks.map { |file| File.basename(file.path) }.sort
    frameworks.each do |file|
      assert_equal 'SDKROOT', file.source_tree
      assert_equal "System/Library/Frameworks/#{File.basename(file.path)}", file.path
    end
    thinning = runner.build_phases.find { |item| item.respond_to?(:name) && item.name == 'Thin Binary' }
    assert_operator runner.build_phases.index(phase), :<, runner.build_phases.index(thinning)
  end

  def test_each_flavour_has_separate_identity_and_shared_flutter_versions
    project = configure
    widget = project.targets.find { |target| target.name == 'AlrtWidget' }
    assert_equal project.build_configurations.map(&:name).sort,
                 widget.build_configurations.map(&:name).sort
    widget.build_configurations.each do |configuration|
      settings = configuration.build_settings
      dev = configuration.name.end_with?('-dev')
      expected_id = dev ? 'com.safetyalrt.alrt.dev.AlrtWidget' : 'com.safetyalrt.alrt.AlrtWidget'
      expected_entitlements = dev ? 'AlrtWidget/AlrtWidget-dev.entitlements' : 'AlrtWidget/AlrtWidget.entitlements'
      assert_equal expected_id, settings['PRODUCT_BUNDLE_IDENTIFIER']
      assert_equal expected_entitlements, settings['CODE_SIGN_ENTITLEMENTS']
      assert_equal '$(FLUTTER_BUILD_NUMBER)', settings['CURRENT_PROJECT_VERSION']
      assert_equal '$(FLUTTER_BUILD_NAME)', settings['MARKETING_VERSION']
      assert_equal 'Generated.xcconfig', File.basename(configuration.base_configuration_reference.path)
      assert_equal 'YES', settings['APPLICATION_EXTENSION_API_ONLY']
      assert_equal 'YES', settings['SKIP_INSTALL']
      assert_equal '15.6', settings['IPHONEOS_DEPLOYMENT_TARGET']
    end
  end

  def test_configuration_is_repeatable_without_changing_runner_signing
    project = configure
    first = File.read(File.join(@path, 'project.pbxproj'))
    configure
    assert_equal first, File.read(File.join(@path, 'project.pbxproj'))
    assert_equal 1, project.targets.count { |target| target.name == 'AlrtWidget' }
    before_runner = @before.targets.find { |target| target.name == 'Runner' }
    after_runner = project.targets.find { |target| target.name == 'Runner' }
    before_runner.build_configurations.each do |before|
      after = after_runner.build_configurations.find { |item| item.name == before.name }
      assert_equal before.build_settings, after.build_settings
    end
  end
end
