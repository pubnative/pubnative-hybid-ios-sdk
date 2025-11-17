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

    // MARK: - Unified API

    /// Assigns the delegate for `context` and pushes it on the active stack.
    @objc public func activateContext(_ context: HyBidAdContext, with delegate: HyBidInterruptionDelegate) {
        setWeakDelegate(delegate, for: context)
        activeContextStack.append(context)
    }

    /// Removes the context from the stack.
    @objc public func deactivateContext(_ context: HyBidAdContext) {
        if let idx = activeContextStack.lastIndex(of: context) {
            activeContextStack.remove(at: idx)
        }
    }

    // MARK: - Routing

    private func setWeakDelegate(_ delegate: HyBidInterruptionDelegate, for context: HyBidAdContext) {
        switch context {
        case .vastPlayer: vastPlayerDelegate = delegate
        case .endcard:    endCardDelegate = delegate
        case .mraidView:  mraidViewDelegate = delegate
        case .nativeAd:   nativeAdDelegate = delegate
        }
    }

    @objc public func activeDelegate() -> HyBidInterruptionDelegate? {
        guard let top = activeContextStack.last else { return nil }
        switch top {
        case .vastPlayer: return vastPlayerDelegate
        case .endcard:    return endCardDelegate
        case .mraidView:  return mraidViewDelegate
        case .nativeAd:   return nativeAdDelegate
        }
    }

    private func notifyNoFocus() {
        activeDelegate()?.adHasNoFocus?()
        overlappingElementDelegate?.adHasNoFocus?()
    }

    private func notifyFocusIfNeeded() {
        guard interruptions.isEmpty else { return }
        activeDelegate()?.adHasFocus?()
        overlappingElementDelegate?.adHasFocus?()
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
        interruptions.append(HyBidInterruption(adFormat: adFormat, type: interruptionType))
        notifyNoFocus()
    }

    private func setAdInterruption(interruptionType: HyBidInterruptionType) {
        interruptions.append(HyBidInterruption(type: interruptionType))
        notifyNoFocus()
    }

    private func removeAdInterruption(interruptionType: HyBidInterruptionType) {
        guard let last = interruptions.last(where: { $0.type == interruptionType }) else { return }
        interruptions.removeAll { $0.id == last.id }
        notifyFocusIfNeeded()
    }

    @objc public func hasOnlyAppLifeCycleInterruption() -> Bool {
        return interruptions.count == 1 && interruptions.last?.type == .appLifeCycle
    }
}

// MARK: - Endcard notifier
extension HyBidInterruptionHandler {
    @objc public func endCardWillShow() {
        overlappingElementDelegate?.endCardWillShow?()
    }
    
    @objc public func customEndCardWillShow() {
        overlappingElementDelegate?.customEndCardWillShow?()
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

