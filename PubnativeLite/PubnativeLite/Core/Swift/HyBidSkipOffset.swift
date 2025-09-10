// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidSkipOffset: NSObject {
    
    @objc public static let DEFAULT_VIDEO_SKIP_OFFSET = 10
    @objc public static let DEFAULT_HTML_SKIP_OFFSET = 3
    @objc public static let DEFAULT_REWARDED_HTML_SKIP_OFFSET = 30
    @objc public static let DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD = 15
    @objc public static let DEFAULT_END_CARD_CLOSE_OFFSET = 3
    @objc public static let DEFAULT_END_CARD_CLOSE_MAX_OFFSET = 30
    @objc public static let DEFAULT_REWARDED_VIDEO_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_INTERSTITIAL_VIDEO_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_REWARDED_HTML_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_INTERSTITIAL_HTML_MAX_SKIP_OFFSET = 30
    @objc public static let DEFAULT_NATIVE_CLOSE_BUTTON_OFFSET = 15
    
    @objc public static let DEFAULT_PC_VIDEO_SKIP_OFFSET = 8
    @objc public static let DEFAULT_PC_VIDEO_MAX_SKIP_OFFSET_COMPANION = 10
    @objc public static let DEFAULT_PC_VIDEO_MAX_SKIP_OFFSET_NON_COMPANION = 15
    
    @objc public static let DEFAULT_PC_INTERSTITIAL_SKIP_OFFSET = 8
    @objc public static let DEFAULT_PC_INTERSTITIAL_MAX_SKIP_OFFSET = 15
    
    @objc public static let DEFAULT_PC_END_CARD_CLOSE_DELAY = 5
    @objc public static let DEFAULT_BC_END_CARD_CLOSE_DELAY = 0

    @objc public var offset: NSNumber?
    @objc public var isCustom: Bool = false
    @objc public var style: NSNumber = 0
    
    @objc
    public init(offset: NSNumber?, isCustom: Bool) {
        super.init()
        configure(offset: offset, isCustom: isCustom, style: 0)
    }
    
    @objc
    public init(offset: NSNumber?, isCustom: Bool, style: NSNumber = 0) {
        super.init()
        configure(offset: offset, isCustom: isCustom, style: style)
    }

    @objc
    public func configure(offset: NSNumber?, isCustom: Bool, style: NSNumber = 0) {
        if offset?.intValue ?? 0 > 99 {
            self.offset = NSNumber(value: 99)
        } else {
            self.offset = offset
        }
        self.isCustom = isCustom
        self.style = style
    }
}
