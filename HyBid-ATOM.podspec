Pod::Spec.new do |s|
  s.name         = "HyBid-ATOM"
  s.version      = "2.9.0-beta1"
  s.summary      = "This is the iOS SDK of HyBid. You can read more about it at https://verve.com."
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

    Copyright (c) 2021 Verve Group Inc.

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

  s.requires_arc     = true
  s.authors      = { "Can Soykarafakili" => "can.soykarafakili@verve.com", "Eros Garcia Ponte" => "eros.ponte@verve.com", "Fares Benhamouda" => "fares.benhamouda@verve.com", "Orkhan Alizada" => "orkhan.alizada@verve.com"  }
  s.platform     = :ios

  s.ios.deployment_target = "9.0"
  s.source       = { :http => "https://github.com/pubnative/pubnative-hybid-ios-sdk/releases/download/2.7.1-ATOM-beta1/HyBid.xcframework.zip" }
  s.vendored_framework = 'HyBid.xcframework'
  s.dependency 'NumberEightCompiled', '= 3.0.4'

end

