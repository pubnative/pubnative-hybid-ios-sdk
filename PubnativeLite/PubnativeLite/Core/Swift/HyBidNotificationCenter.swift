//
//  Copyright © 2021 PubNative. All rights reserved.
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
