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
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var interstitialHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var rewardedHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var endCardCloseOffset = HyBidSkipOffset(offset: NSNumber(value: DEFAULT_END_CARD_CLOSE_OFFSET), isCustom: false)
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var showEndCard: Bool = false {
        didSet {
            if !videoSkipOffset.isCustom {
                let skipOffset = showEndCard ? DEFAULT_VIDEO_SKIP_OFFSET : DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD
                videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: skipOffset), isCustom: false)
            }
        }
    }
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var interstitialActionBehaviour: HyBidInterstitialActionBehaviour = HB_CREATIVE
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var interstitialCloseOnFinish: Bool = false
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var rewardedCloseOnFinish: Bool = false
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var audioStatus: HyBidAudioStatus = HyBidAudioStatusMuted
    @objc public var mraidExpand: Bool = true
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var interstitialSKOverlay: Bool = false
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var rewardedSKOverlay: Bool = false
    
    @available(*, deprecated, message: "You can safely remove this method from your integration.")
    @objc public var bannerSKOverlay: Bool {
        return false
    }
}
