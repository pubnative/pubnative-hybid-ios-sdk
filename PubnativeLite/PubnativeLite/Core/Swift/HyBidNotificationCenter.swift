// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public enum HyBidNotificationType: Int32 {
    
    case SKStoreProductViewIsReadyToPresent
    case SKStoreProductViewIsReadyToPresentForSDKStorekit
    case SKStoreProductViewIsShown
    case SKStoreProductViewIsDismissed
    case SKStoreProductViewIsDismissedFromVideo
    
    case AdFeedbackViewIsDismissed
    case AdFeedbackViewDidShow
    
    case InternalWebBrowserDidShow
    case InternalWebBrowserDidDismissed
    
    var name: String {
        
        switch self {
        case .SKStoreProductViewIsReadyToPresent: return "SKStoreProductViewIsReadyToPresent"
        case .SKStoreProductViewIsReadyToPresentForSDKStorekit: return "SKStoreProductViewIsReadyToPresentForSDKStorekit"
        case .SKStoreProductViewIsShown: return "SKStoreProductViewIsShown"
        case .SKStoreProductViewIsDismissed: return "SKStoreProductViewIsDismissed"
        case .SKStoreProductViewIsDismissedFromVideo: return "SKStoreProductViewIsDismissedFromVideo"
            
        case .AdFeedbackViewIsDismissed: return "adFeedbackViewIsDismissed"
        case .AdFeedbackViewDidShow: return "adFeedbackViewDidShow"
            
        case .InternalWebBrowserDidShow: return "internalWebBrowserDidShow"
        case .InternalWebBrowserDidDismissed: return "internalWebBrowserDidDismissed"
        }
    }
}

@objc
public class HyBidNotificationCenter: NSObject {
    
    @objc public static let shared = HyBidNotificationCenter()
    private let notificationCenter = NotificationCenter.default

    private override init() {
        super.init()
    }
    
    @objc public func post(_ notificationType: HyBidNotificationType, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil){
        notificationCenter.post(name: Notification.Name(notificationType.name), object: object, userInfo: userInfo)
    }
    
    @objc public func addObserver(_ observer: Any, selector: Selector, notificationType: HyBidNotificationType, object: Any?){
        notificationCenter.addObserver(observer, selector: selector, name: Notification.Name(notificationType.name), object: object)
    }
}
