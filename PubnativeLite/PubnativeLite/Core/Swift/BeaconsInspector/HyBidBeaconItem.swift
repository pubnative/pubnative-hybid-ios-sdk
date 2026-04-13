//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc(HyBidBeaconItem)
public class HyBidBeaconItem: NSObject {

    @objc public let type: String
    @objc public let url: String?
    @objc public let js: String?

    @objc public var content: String {
        url ?? js ?? ""
    }

    @objc
    public init(type: String, url: String?, js: String?) {
        self.type = type
        self.url = url
        self.js = js
        super.init()
    }
}
