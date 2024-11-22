Pod::Spec.new do |s|
  s.name         = "HyBid"
  s.version      = "3.2.0-beta3"
  s.summary      = "This is the iOS SDK of HyBid. You can read more about it at https://pubnative.net."
  s.description = <<-DESC
                     HyBid leverages first-look prebid technology to maximize yield for the publishers across
                     their current monetization suit. Access to the unique demand across different formats allows
                     publishers to immediately benefit with additional revenues on top of their current yield. Prebid technology
                     allows getting a competitive bid before executing your regular waterfall logic, and then
                     participate in the relevant auctions in the cascade.
                   DESC
  s.homepage     = "https://github.com/pubnative/pubnative-hybid-ios-sdk"
  s.documentation_url = "https://developers.verve.com/v3.0/docs/hybid"
  s.license             = { :type => "MIT", :text => <<-LICENSE
    MIT License

    Copyright (c) 2024 PubNative GmbH

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
      LICENSE
    }

  s.authors      = { "Can Soykarafakili" => "can.soykarafakili@pubnative.net", "Eros Garcia Ponte" => "eros.ponte@pubnative.net", "Fares Benhamouda" => "fares.benhamouda@pubnative.net", "Orkhan Alizada" => "orkhan.alizada@pubnative.net", "Jose Contreras" => "jose.contreras@verve.com", "Aysel Abdullayeva" => "aysel.abdullayeva@verve.com"  }
  s.platform     = :ios

  s.ios.deployment_target = "12.0"
  s.source       = { :git => "https://github.com/pubnative/pubnative-hybid-ios-sdk.git", :tag => "3.2.0-beta3" }
  s.resource_bundle = {
    "#{s.module_name}Resources" => "PubnativeLite/PubnativeLite/PrivacyInfo.xcprivacy"
  }
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-framework OMSDK_Pubnativenet'
  }

  s.swift_version = '5.0'
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-Xcc -Wno-incomplete-umbrella'
  }

  s.subspec 'Core' do |core|
    core.source_files          = 'PubnativeLite/PubnativeLite/Core/**/*.{swift,h,m}'
    core.resources            =  ['PubnativeLite/PubnativeLite/Resources/**/*', 'PubnativeLite/PubnativeLite/OMSDK-1.5.2/*.js', 'PubnativeLite/PubnativeLite/Core/MRAID/*.js']
    core.exclude_files         = 'PubnativeLite/PubnativeLite/Core/Public/HyBidStatic.{swift,h,m}'
    core.vendored_frameworks   = ['PubnativeLite/PubnativeLite/OMSDK-1.5.2/*.{xcframework}']
    core.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/HyBid/module' }
    core.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2 $(PODS_ROOT)/HyBid/module' }
    core.public_header_files = ['PubnativeLite/PubnativeLite/Core/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Viewability/Public/*.h' , 'PubnativeLite/PubnativeLite/Core/Consent/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Model/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Request/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Cache/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Ad Presenter/Public/*.h', 'PubnativeLite/PubnativeLite/Core/MRAID/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Remote Config/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Auction/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Utils/Public/*.h', 'PubnativeLite/PubnativeLite/Core/VAST/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Analytics/Public/*.h', 'PubnativeLite/PubnativeLite/Core/Config/Public/*.h']

  end

  s.subspec 'Banner' do |banner|
    banner.dependency           'HyBid/Core'
    banner.source_files         = ['PubnativeLite/PubnativeLite/Banner/**/*.{swift,h,m}']
    banner.public_header_files = ['PubnativeLite/PubnativeLite/Banner/**/*.h']
  end

  s.subspec 'Native' do |native|
    native.dependency           'HyBid/Core'
    native.source_files     = ['PubnativeLite/PubnativeLite/Native/**/*.{swift,h,m}']
    native.public_header_files = ['PubnativeLite/PubnativeLite/Native/**/*.h']
  end

  s.subspec 'FullScreen' do |fullscreen|
    fullscreen.dependency       'HyBid/Core'
    fullscreen.source_files     = ['PubnativeLite/PubnativeLite/FullScreen/**/*.{swift,h,m}']
    fullscreen.public_header_files = ['PubnativeLite/PubnativeLite/FullScreen/Public/*.h']
  end

  s.subspec 'RewardedVideo' do |rewarded|
    rewarded.dependency         'HyBid/Core'
    rewarded.source_files       = ['PubnativeLite/PubnativeLite/Rewarded/**/*.{swift,h,m}']
    rewarded.public_header_files = ['PubnativeLite/PubnativeLite/Rewarded/Public/*.h']
  end

  s.subspec 'ATOM' do |atom|
    atom.dependency 'HyBid/Core'
    atom.dependency 'ATOM-Standalone', '~> 3.3.3'
  end

  s.default_subspecs = ['Core', 'Banner', 'Native', 'FullScreen', 'RewardedVideo', 'ATOM']
  
end
