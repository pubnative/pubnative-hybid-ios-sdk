//
//  Copyright © 2020 PubNative. All rights reserved.
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
public class HyBidConstants: NSObject {
    
    @objc public static let HYBID_SDK_NAME = "HyBid"
    @objc public static let HYBID_SDK_VERSION = "3.0.0-beta1"
    @objc public static let HYBID_OMSDK_VERSION = "1.4.8"
    @objc public static let HYBID_OMSDK_IDENTIFIER = "Pubnativenet"
    
    //Rendering Constants
    @objc public static var mraidExpand: Bool = true
    @objc public static var showEndCard: Bool = true
    @objc public static var showCustomEndCard: Bool = false
    @objc public static var customEndcardDisplay: HyBidCustomEndcardDisplayBehaviour = HyBidCustomEndcardDisplayFallback
    @objc public static var interstitialCloseOnFinish: Bool = false
    @objc public static var rewardedCloseOnFinish: Bool = false
    @objc public static var rewardedHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    @objc public static var rewardedVideoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_REWARDED_VIDEO_SKIP_OFFSET), isCustom: false)
    @objc public static var interstitialHtmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    @objc public static var videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
    @objc public static var interstitialActionBehaviour: HyBidInterstitialActionBehaviour = HB_CREATIVE
    @objc public static var endCardCloseOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_END_CARD_CLOSE_OFFSET), isCustom: false)
    @objc public static var nativeCloseButtonOffset = HyBidSkipOffset(offset: NSNumber(value: HyBidSkipOffset.DEFAULT_NATIVE_CLOSE_BUTTON_OFFSET), isCustom: false)
    @objc public static var audioStatus: HyBidAudioStatus = HyBidAudioStatusON
    @objc public static var creativeAutoStorekitEnabled: Bool = false
}
