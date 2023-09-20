//
//  Copyright © 2022 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

@objc
public class HyBidRenderingConfig: NSObject {
    @objc public static let sharedConfig = HyBidRenderingConfig()
    
    private override init() {}
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var interstitialHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var rewardedHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var rewardedVideoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_REWARDED_VIDEO_SKIP_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var endCardCloseOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_END_CARD_CLOSE_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var nativeCloseButtonOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_NATIVE_CLOSE_BUTTON_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var showEndCard: Bool = true {
        didSet {
            if !videoSkipOffset.isCustom {
                let skipOffset = showEndCard ? HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET : HyBidSkipOffset.DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD
                videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: skipOffset), isCustom: false)
            }
        }
    }
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var customEndCard: Bool = false
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var interstitialActionBehaviour: HyBidInterstitialActionBehaviour = HB_CREATIVE
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var interstitialCloseOnFinish: Bool = false
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var rewardedCloseOnFinish: Bool = false
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var audioStatus: HyBidAudioStatus = HyBidAudioStatusON
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var mraidExpand: Bool = true
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var interstitialSKOverlay: Bool = false
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var rewardedSKOverlay: Bool = false
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var customEndcardDisplay: HyBidCustomEndcardDisplayBehaviour = HyBidCustomEndcardDisplayFallback
    
    @available(*, deprecated, message: "Please note this method will no longer be supported from HyBid SDK v3.0. While we do not recommend changes to this setting, you can reach out to your account managers for customisations.")
    @objc public var creativeAutoStorekitEnabled: Bool = false

}
