source 'https://cdn.cocoapods.org/'

workspace 'HyBid.xcworkspace'
project 'PubnativeLite/HyBid.xcodeproj'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

target 'HyBidDemo' do
  # Pods for HyBidDemo
  pod 'FLEX', '4.4.1'
  pod 'Firebase/Performance', '8.13.0'
  pod 'Firebase/Crashlytics', '8.13.0'
  pod 'mopub-ios-sdk', '5.18.0'
  pod 'Google-Mobile-Ads-SDK', '8.13.0'
  pod 'GoogleMobileAdsMediationTestSuite'
  pod 'AppLovinSDK', '11.3.0'
end

target 'HyBidTests' do
  inherit! :search_paths
  pod 'OCMockito', '7.0.1'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
  end
 end
end
