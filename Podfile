# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'HabitsTracker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for HabitsTracker
  pod 'YandexMobileMetrica/Dynamic', '~> 4.5.0'

  target 'HabitsTrackerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
  end
 end
end
