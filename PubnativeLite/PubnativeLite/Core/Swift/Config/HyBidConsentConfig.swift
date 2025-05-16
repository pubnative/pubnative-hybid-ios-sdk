// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidConsentConfig: NSObject {
    @objc public static let sharedConfig = HyBidConsentConfig()
    
    private override init() {}
    
    @objc public var coppa: Bool = false
}
