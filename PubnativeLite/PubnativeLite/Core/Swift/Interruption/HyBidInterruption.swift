// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

enum HyBidInterruptionType {
    case storeKitView
    case autoStoreKitView
    case appLifeCycle
    case feedbackView
    case internalBrowser
}

struct HyBidInterruption {
    var adFormat: String? = .none
    let type: HyBidInterruptionType
    let id = UUID()
}
