//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@objc
public class HyBidInterruptionHandler: NSObject {
    
    @objc public static let shared: HyBidInterruptionHandler = HyBidInterruptionHandler()
    @objc public weak var delegate: HyBidInterruptionDelegate?
    @objc public weak var overlappingElementDelegate: HyBidInterruptionDelegate?
    @objc public weak var feedbackViewDelegate: HyBidAdFeedbackViewDelegate?
    private var interruptions = [HyBidInterruption]()
    
    public override init() {
        super.init()
        self.addObservers()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    private func setAdInterruption(adFormat: String, interruptionType: HyBidInterruptionType) {
        let interruption = HyBidInterruption(adFormat: adFormat, type: interruptionType)
        self.interruptions.append(interruption)
        self.delegate?.adHasNoFocus?()
        self.overlappingElementDelegate?.adHasNoFocus?()
    }
    
    private func setAdInterruption(interruptionType: HyBidInterruptionType) {
        let interruption = HyBidInterruption(type: interruptionType)
        self.interruptions.append(interruption)
        self.delegate?.adHasNoFocus?()
        self.overlappingElementDelegate?.adHasNoFocus?()
    }
    
    private func removeAdInterruption(interruptionType: HyBidInterruptionType) {
        guard let lastInterruption = self.interruptions.filter({ $0.type == interruptionType}).last else { return }
        self.interruptions.removeAll(where: {$0.id == lastInterruption.id})
        if self.interruptions.isEmpty {
            self.delegate?.adHasFocus?()
            self.overlappingElementDelegate?.adHasFocus?()
        }
    }
    
    @objc public func hasOnlyAppLifeCycleInterruption() -> Bool {
        guard self.interruptions.count == 1,
              let lastInterruption = self.interruptions.last,
              lastInterruption.type == .appLifeCycle else { return false }
        
        return true
    }
}

//MARK: - Endcard notifier

extension HyBidInterruptionHandler {
    
    @objc public func vastEndCardWillShow() {
        self.overlappingElementDelegate?.vastEndCardWillShow?()
    }
    
    @objc public func vastCustomEndCardWillShow() {
        self.overlappingElementDelegate?.vastCustomEndCardWillShow?()
    }
}

//MARK: - App life cycle
extension HyBidInterruptionHandler {
    
    @objc private func willResignActive() {
        self.setAdInterruption(interruptionType: .appLifeCycle)
    }
    
    @objc private func didBecomeActive() {
        self.removeAdInterruption(interruptionType: .appLifeCycle)
    }
    
    @objc private func willEnterForeground() {
        self.delegate?.willEnterForeground?()
        self.overlappingElementDelegate?.willEnterForeground?()
    }
}

//MARK: - SKStoreProductViewControllerDelegate
extension HyBidInterruptionHandler {
    
    public func productViewControllerIsReadyToShow() {
        self.overlappingElementDelegate?.productViewControllerIsReadyToShow?()
    }
    
    public func productViewControllerWillShow() {
        self.overlappingElementDelegate?.productViewControllerWillShow?()
    }
    
    public func productViewControllerDidShow(isAutoStoreKitView: Bool, adFormat: String) {
        self.setAdInterruption(adFormat: adFormat,
                               interruptionType: isAutoStoreKitView
                               ? .autoStoreKitView
                               : .storeKitView)
        self.delegate?.productViewControllerDidShow?()
    }
    
    public func productViewControllerDidFinish() {
        HyBidSKAdNetworkViewController.shared.isStoreKitViewPresented = false
        if let lastInterruption = self.interruptions.filter({ $0.type == .storeKitView || $0.type == .autoStoreKitView}).last {
            if HyBidSDKConfig.sharedConfig.reporting {
                let reportingEvent = HyBidReportingEvent(with: EventType.STOREKIT_PRODUCT_VIEW_DISMISS, adFormat: lastInterruption.adFormat)
                HyBid.reportingManager().reportEvent(for: reportingEvent)
            }
            self.removeAdInterruption(interruptionType: lastInterruption.type)
        }
        self.delegate?.productViewControllerDidFinish?()
        self.overlappingElementDelegate?.productViewControllerDidFinish?()
    }
    
    @objc public func productViewControllerDidFail(error: Error) {
        self.delegate?.productViewControllerDidFail?(error: error)
    }
}

//MARK: - HyBidAdFeedbackViewDelegate
extension HyBidInterruptionHandler: HyBidAdFeedbackViewDelegate {
    
    public func adFeedbackViewDidLoad() {
        self.feedbackViewDelegate?.adFeedbackViewDidLoad?()
    }
    
    @objc public func adFeedbackViewWillShow() {
        self.delegate?.feedbackViewWillShow?()
        self.overlappingElementDelegate?.feedbackViewWillShow?()
    }
    
    @objc public func adFeedbackViewDidShow() {
        self.setAdInterruption(interruptionType: .feedbackView)
    }
    
    public func adFeedbackViewDidFailWithError(_ error: any Error) {
        let error = error as NSError
        self.feedbackViewDelegate?.adFeedbackViewDidFailWithError?(error)
    }

    public func adFeedbackViewDidDismiss() {
        self.removeAdInterruption(interruptionType: .feedbackView)
        self.delegate?.feedbackViewDidDismiss?()
    }
}

//MARK: - HyBidInternalWebBrowserDelegate
extension HyBidInterruptionHandler: HyBidInternalWebBrowserDelegate {
    
    public func internalWebBrowserDidShow() {
        self.setAdInterruption(interruptionType: .internalBrowser)
        self.delegate?.internalWebBrowserDidShow?()
    }
    
    public func internalWebBrowserDidDismiss() {
        self.removeAdInterruption(interruptionType: .internalBrowser)
    }
}
