// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidTargetingModel: NSObject {
    @objc public var age: NSNumber?
    @objc public var interests: [String] = []
    @objc public var gender: String?
}
