//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@objc public enum HyBidAdContext: Int {
    case vastPlayer
    case endcard
    case mraidView
    case nativeAd
}

@objc
public class HyBidInterruptionHandler: NSObject {

    @objc public static let shared = HyBidInterruptionHandler()

    // MARK: - Context-specific delegates (all weak)
    private weak var vastPlayerDelegate: HyBidInterruptionDelegate?
    private weak var endCardDelegate: HyBidInterruptionDelegate?
    private weak var mraidViewDelegate: HyBidInterruptionDelegate?
    private weak var nativeAdDelegate: HyBidInterruptionDelegate?

    // Other delegates you already expose
    @objc public weak var overlappingElementDelegate: HyBidInterruptionDelegate?
    @objc public weak var feedbackViewDelegate: HyBidAdFeedbackViewDelegate?

    private var interruptions = [HyBidInterruption]()

    private var activeContextStack: [HyBidAdContext] = []

    public override init() {
        super.init()
        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Register & activate

    /// Register a delegate for a specific context (call once per owner lifecycle).
    @objc public func setDelegate(_ delegate: HyBidInterruptionDelegate, for context: HyBidAdContext) {
        switch context {
        case .vastPlayer:        vastPlayerDelegate = delegate
        case .endcard:           endCardDelegate = delegate
        case .mraidView:         mraidViewDelegate = delegate
        case .nativeAd:          nativeAdDelegate = delegate
        }
    }

    /// Make this context the current receiver (push on stack).
    @objc public func activateContext(_ context: HyBidAdContext) {
        activeContextStack.append(context)
    }

    /// Remove this context from the stack (usually on dismiss/deinit).
    @objc public func deactivateContext(_ context: HyBidAdContext) {
        if let idx = activeContextStack.lastIndex(of: context) {
            activeContextStack.remove(at: idx)
        }
    }

    // MARK: - Routing helpers

    @objc public func activeDelegate() -> HyBidInterruptionDelegate? {
        guard let top = activeContextStack.last else { return nil }
        switch top {
        case .vastPlayer:        return vastPlayerDelegate
        case .endcard:           return endCardDelegate
        case .mraidView:         return mraidViewDelegate
        case .nativeAd:          return nativeAdDelegate
        }
    }

    private func notifyNoFocus() {
        activeDelegate()?.adHasNoFocus?()
        overlappingElementDelegate?.adHasNoFocus?()
    }

    private func notifyFocusIfNeeded() {
        if interruptions.isEmpty {
            activeDelegate()?.adHasFocus?()
            overlappingElementDelegate?.adHasFocus?()
        }
    }

    // MARK: - Observers

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - Interruption bookkeeping

    private func setAdInterruption(adFormat: String, interruptionType: HyBidInterruptionType) {
        let interruption = HyBidInterruption(adFormat: adFormat, type: interruptionType)
        interruptions.append(interruption)
        notifyNoFocus()
    }

    private func setAdInterruption(interruptionType: HyBidInterruptionType) {
        let interruption = HyBidInterruption(type: interruptionType)
        interruptions.append(interruption)
        notifyNoFocus()
    }

    private func removeAdInterruption(interruptionType: HyBidInterruptionType) {
        guard let last = interruptions.last(where: { $0.type == interruptionType }) else { return }
        interruptions.removeAll { $0.id == last.id }
        notifyFocusIfNeeded()
    }

    @objc public func hasOnlyAppLifeCycleInterruption() -> Bool {
        guard interruptions.count == 1,
              let last = interruptions.last,
              last.type == .appLifeCycle else { return false }
        return true
    }
}

// MARK: - Endcard notifier
extension HyBidInterruptionHandler {
    @objc public func endCardWillShow() {
        self.overlappingElementDelegate?.endCardWillShow?()
    }
    
    @objc public func customEndCardWillShow() {
        self.overlappingElementDelegate?.customEndCardWillShow?()
    }
}

//MARK: - App life cycle
extension HyBidInterruptionHandler {
    @objc private func willResignActive() {
        setAdInterruption(interruptionType: .appLifeCycle)
    }
    @objc private func didBecomeActive() {
        removeAdInterruption(interruptionType: .appLifeCycle)
    }
    @objc private func willEnterForeground() {
        activeDelegate()?.willEnterForeground?()
        overlappingElementDelegate?.willEnterForeground?()
    }
}

// MARK: - SK / StoreKit passthroughs
extension HyBidInterruptionHandler {
    public func productViewControllerIsReadyToShow() {
        overlappingElementDelegate?.productViewControllerIsReadyToShow?()
    }
    public func productViewControllerWillShow() {
        overlappingElementDelegate?.productViewControllerWillShow?()
    }
    public func productViewControllerDidShow(isAutoStoreKitView: Bool, adFormat: String) {
        setAdInterruption(adFormat: adFormat,
                          interruptionType: isAutoStoreKitView ? .autoStoreKitView : .storeKitView)
        activeDelegate()?.productViewControllerDidShow?()
    }
    public func productViewControllerDidFinish() {
        HyBidSKAdNetworkViewController.shared.isStoreKitViewPresented = false
        if let last = interruptions.last(where: { $0.type == .storeKitView || $0.type == .autoStoreKitView }) {
            if HyBidSDKConfig.sharedConfig.reporting {
                let event = HyBidReportingEvent(with: EventType.STOREKIT_PRODUCT_VIEW_DISMISS,
                                                adFormat: last.adFormat)
                HyBid.reportingManager().reportEvent(for: event)
            }
            removeAdInterruption(interruptionType: last.type)
        }
        activeDelegate()?.productViewControllerDidFinish?()
        overlappingElementDelegate?.productViewControllerDidFinish?()
    }
    @objc public func productViewControllerDidFail(error: Error) {
        activeDelegate()?.productViewControllerDidFail?(error: error)
    }
}

//MARK: - HyBidAdFeedbackViewDelegate
extension HyBidInterruptionHandler: HyBidAdFeedbackViewDelegate {
    public func adFeedbackViewDidLoad() {
        feedbackViewDelegate?.adFeedbackViewDidLoad?()
    }
    @objc public func adFeedbackViewWillShow() {
        activeDelegate()?.feedbackViewWillShow?()
        overlappingElementDelegate?.feedbackViewWillShow?()
    }
    @objc public func adFeedbackViewDidShow() {
        setAdInterruption(interruptionType: .feedbackView)
    }
    public func adFeedbackViewDidFailWithError(_ error: any Error) {
        feedbackViewDelegate?.adFeedbackViewDidFailWithError?(error as NSError)
    }
    public func adFeedbackViewDidDismiss() {
        removeAdInterruption(interruptionType: .feedbackView)
        activeDelegate()?.feedbackViewDidDismiss?()
    }
}

// MARK: - Internal browser
extension HyBidInterruptionHandler: HyBidInternalWebBrowserDelegate {
    public func internalWebBrowserDidShow() {
        setAdInterruption(interruptionType: .internalBrowser)
        activeDelegate()?.internalWebBrowserDidShow?()
    }
    public func internalWebBrowserDidDismiss() {
        removeAdInterruption(interruptionType: .internalBrowser)
    }
}

