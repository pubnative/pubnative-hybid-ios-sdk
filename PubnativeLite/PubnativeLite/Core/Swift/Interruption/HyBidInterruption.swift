// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

enum HyBidInterruptionType {
    case skStoreProductViewController
    case autoSKStoreProductViewController
    case appLifeCycle
    case feedbackView
    case internalBrowser
}

struct HyBidInterruption {
    var adformat: String? = .none
    let type: HyBidInterruptionType
    let id = UUID()
}
