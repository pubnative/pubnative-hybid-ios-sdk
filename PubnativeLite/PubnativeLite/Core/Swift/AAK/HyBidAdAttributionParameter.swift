//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@objc public class HyBidAdAttributionParameter: NSObject {
    @objc public static let jwt = "jwt"
    @objc public static let custom_market_place = "custom_market_place"
    @objc public static let reengagement_url = "reengagement_url"
}

enum HyBidAdAttributionAdType: String {
    case skoverlay
    case storeKitView
    case autoStoreKitView
    case viewThrough
    case clickThrough
}
