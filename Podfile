source 'https://cdn.cocoapods.org/'

workspace 'HyBid.xcworkspace'
project 'PubnativeLite/HyBid.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

use_frameworks!

target 'HyBid' do
  pod 'ATOM-Standalone', '1.0.0-beta2'
end

target 'HyBidDemo' do
  # Pods for HyBidDemo
  pod 'FLEX', :configurations => ['Debug']
  pod 'Firebase/Performance', '8.13.0'
  pod 'Firebase/Crashlytics', '8.13.0'
  pod 'Google-Mobile-Ads-SDK'
  pod 'AppLovinSDK', '11.4.0'
end

target 'HyBidTests' do
  inherit! :search_paths
  pod 'OCMockito', '7.0.1'
end

targets_to_weaklink=['HyBid']
frameworks_to_weaklink=['ATOM-Standalone', 'ATOM']

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
  
  # Weak-Linking ATOM to HyBid
  targets_to_weaklink.map!{|t| t="Pods-#{t}"}
  installer.pods_project.targets.each do |target|
    next unless targets_to_weaklink.include?(target.name)
    
    target.build_configurations.each do |config|
      base_config_reference = config.base_configuration_reference
      unless base_config_reference.nil?
        xcconfig_path = base_config_reference.real_path
        xcconfig = File.read(xcconfig_path)
        frameworks_to_weaklink.each do |framework|
          xcconfig = xcconfig.gsub(/-framework "#{framework}"/, "-weak_framework \"#{framework}\"")
        end
        File.open(xcconfig_path, "w") { |file| file << xcconfig }
      end
    end
  end
end
