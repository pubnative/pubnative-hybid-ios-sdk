// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidViewbilityConfig: NSObject {
    @objc public static let sharedConfig = HyBidViewbilityConfig()
    
    private override init() {}
    
    @objc public var impressionTrackerMethod: HyBidImpressionTrackerMethod = HyBidAdImpressionTrackerViewable
    @objc public var minVisibleTime: Int = 0
    @objc public var minVisiblePercent: Double = 0.0

}
