//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@objc
public protocol HyBidInterruptionDelegate: NSObjectProtocol {
    
    @objc optional func adHasNoFocus()
    @objc optional func adHasFocus()
    
    @objc optional func endCardWillShow()
    @objc optional func customEndCardWillShow()
    
    @objc optional func willEnterForeground()
    
    @objc optional func feedbackViewWillShow()
    @objc optional func feedbackViewDidDismiss()
    
    @objc optional func productViewControllerIsReadyToShow()
    @objc optional func productViewControllerWillShow()
    @objc optional func productViewControllerDidShow()
    @objc optional func productViewControllerDidFail(error: Error)
    @objc optional func productViewControllerDidFinish()
    
    @objc optional func internalWebBrowserDidShow()
}
