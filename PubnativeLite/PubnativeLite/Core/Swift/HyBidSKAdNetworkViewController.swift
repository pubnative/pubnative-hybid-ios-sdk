//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import AdAttributionKit
import StoreKit

private var productParametersGlobal: Dictionary<String,Any> = [:]

private struct HyBidStoreProductHelper {
    static var productViewControllerDidFinishHasBeenCalled = false
    static var presentedViewControllerHasBeenFalse = false
    static let transitionDuration = 0.5
}

private let STOREKIT_DELAY_MAXIMUM_VALUE = 35
private let STOREKIT_DELAY_MINIMUM_VALUE = 0
private let STOREKIT_DELAY_DEFAULT_VALUE = 2

@objc
public class HyBidSKAdNetworkViewController: NSObject {
    
    @objc public static let shared = HyBidSKAdNetworkViewController()
    public var isStoreKitViewPresented = false {
        didSet {
            if isStoreKitViewPresented { isStoreKitViewBeingPresented = false }
        }
    }
    private var isStoreKitViewBeingPresented = false
    var skStoreProductViewController : SKStoreProductViewController?
    private var ad: HyBidAd?
    @objc public var avoidAutoStoreKitPresentationAfterReplay = false
    var topViewControllerProvider: () -> UIViewController? = { UIApplication.shared.topViewController }
    
    @available(iOS 17.4, *)
    private func loadStoreKitViewAAK(parameters: [String : Any], adFormat: String, isAutoStoreKitView: Bool, preferredPresenter: UIViewController?) async {
        let aakAdType: HyBidAdAttributionAdType = isAutoStoreKitView ? .autoStoreKitView : .storeKitView
        guard Self.canLoadStoreKitProductWithAAK(parameters: parameters) else {
            let message = "Falling back to legacy StoreKit loading because AdAttributionKit does not support binary product parameters."
            HyBidLogger.warningLog(fromClass: String(describing: HyBidSKAdNetworkViewController.self), fromMethod: #function, withMessage: message)
            if HyBidSDKConfig.sharedConfig.reporting {
                let eventType = EventType.AD_ATTRIBUTION_KIT_APP_IMPRESSION_ERROR.replacingOccurrences(of: EventType.AD_ATTRIBUTION_KIT_AD_TYPE_MACRO, with: aakAdType.rawValue)
                HyBid.reportingManager().reportEvent(for: HyBidReportingEvent(with: eventType, errorMessage: message))
            }
            return self.loadStoreKitView(parameters: parameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, preferredPresenter: preferredPresenter)
        }
        guard let ad,
              let impression = await HyBidAdAttributionManager.getAppImpression(ad: ad, adFormat: adFormat, aakAdType: aakAdType) else {
            return self.loadStoreKitView(parameters: parameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, preferredPresenter: preferredPresenter)
        }
        do {
#if !targetEnvironment(simulator)
            
            if #available(iOS 18.0, *), let reengagementURL = await HyBidAdAttributionManager.getReengagementURL(ad: ad) {
                try await self.skStoreProductViewController?.loadProduct(parameters: parameters, impression: impression, reengagementURL: reengagementURL)
            } else {
                try await self.skStoreProductViewController?.loadProduct(parameters: parameters, impression: impression)
            }
#endif
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.presentStoreKitViewOnTopViewController(handlerController: self, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, preferredPresenter: preferredPresenter)
            }
        } catch {
            _ = self.isStoreKitViewResultSuccessful(error: error)
        }
    }
    
    private func loadStoreKitView(parameters: [String : Any], adFormat: String, isAutoStoreKitView: Bool, preferredPresenter: UIViewController?) {
        self.skStoreProductViewController?.loadProduct(withParameters: parameters) { success, error in
#if !targetEnvironment(simulator)
            guard self.isStoreKitViewResultSuccessful(error: error, success: success) else { return }
#endif
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.presentStoreKitViewOnTopViewController(handlerController: self, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, preferredPresenter: preferredPresenter)
            }
        }
    }
    
    func presentStoreKitViewOnTopViewController(handlerController: HyBidSKAdNetworkViewController?,
                                                 adFormat: String,
                                                 isAutoStoreKitView: Bool,
                                                 preferredPresenter: UIViewController?) {
        guard let handlerController, handlerController.isStoreKitViewPresented == false,
              handlerController.isStoreKitViewBeingPresented == false else {
            HyBidLogger.infoLog(fromClass: String(describing: HyBidSKAdNetworkViewController.self), fromMethod: #function, withMessage: "Suppressing an attempt to manual/auto click when task is not finished yet")
            return
        }
        
        if self.avoidAutoStoreKitPresentationAfterReplay && isAutoStoreKitView {
            HyBidLogger.infoLog(fromClass: String(describing: HyBidSKAdNetworkViewController.self), fromMethod: #function, withMessage: "Suppressing an attempt to auto click after ad replay")
            self.avoidAutoStoreKitPresentationAfterReplay = false
            return
        }
        

        guard let skVC = handlerController.skStoreProductViewController else {
            handlerController.isStoreKitViewBeingPresented = false
            handlerController.isStoreKitViewPresented = false
            return
        }
        let livePresenter = preferredPresenter.flatMap { $0.viewIfLoaded?.window != nil ? $0 : nil }
        guard let presenter = livePresenter ?? self.topViewControllerProvider() else {
            handlerController.isStoreKitViewBeingPresented = false
            handlerController.isStoreKitViewPresented = false
            return
        }

        handlerController.isStoreKitViewBeingPresented = true
        HyBidInterruptionHandler.shared.productViewControllerIsReadyToShow()
        //Re-set flag to avoid bug blocking productViewControllerDidFinish call
        HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled = false
        
        DispatchQueue.main.async {
            presenter.present(skVC, animated: true) {
                handlerController.isStoreKitViewBeingPresented = false
                handlerController.isStoreKitViewPresented = true
                HyBidInterruptionHandler.shared.productViewControllerDidShow(
                    isAutoStoreKitView: isAutoStoreKitView, adFormat: adFormat
                )
            }
        }
    }


    private func isStoreKitViewResultSuccessful(error: Error?, success: Bool = false) -> Bool {
        guard success == false else { return true }
        HyBidLogger.errorLog(fromClass: String(describing: HyBidSKAdNetworkViewController.self), fromMethod: #function, withMessage: "Loading the ad failed, try to load another ad or retry the current ad.")
        self.isStoreKitViewPresented = false
        self.isStoreKitViewBeingPresented = false
        guard let error else { return false }
        HyBidInterruptionHandler.shared.productViewControllerDidFail(error: error)
        return false
    }
    
    @objc public func presentStoreKitView(productParameters: Dictionary<String,Any>, adFormat: String,
                                          isAutoStoreKitView: Bool, ad:HyBidAd, rootViewController: UIViewController) {
        self.presentStoreKitView(productParameters: productParameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, ad: ad, preferredPresenter: rootViewController)
    }
    
    @objc public func presentStoreKitView(productParameters: Dictionary<String,Any>, adFormat: String,
                                          isAutoStoreKitView: Bool, ad:HyBidAd) {
        self.presentStoreKitView(productParameters: productParameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, ad: ad, preferredPresenter: nil)
    }
    
    private func presentStoreKitView(productParameters: Dictionary<String,Any>, adFormat: String,
                                     isAutoStoreKitView: Bool, ad:HyBidAd, preferredPresenter: UIViewController?) {
        guard !productParameters.isEmpty else { return }
        productParametersGlobal = productParameters
        self.ad = ad
        
        DispatchQueue.main.async {
            self.skStoreProductViewController = SKStoreProductViewController()
            self.skStoreProductViewController?.delegate = self
            HyBidInterruptionHandler.shared.productViewControllerWillShow()

            if #available(iOS 17.4, *) {
                self.loadStoreKitViewAAKAsync(parameters: productParameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, preferredPresenter: preferredPresenter)
            } else {
                DispatchQueue.global().async {
                    self.loadStoreKitView(parameters: productParameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, preferredPresenter: preferredPresenter)
                }
            }
        }
    }

    @available(iOS 17.4, *)
    private func loadStoreKitViewAAKAsync(parameters: Dictionary<String,Any>, adFormat: String, isAutoStoreKitView: Bool, preferredPresenter: UIViewController?) {
        Task { [weak self] in
            guard let self else { return }
            await self.loadStoreKitViewAAK(parameters: parameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, preferredPresenter: preferredPresenter)
        }
    }
    
    @objc public func isSKProductViewControllerPresented() -> Bool {
        return self.isStoreKitViewPresented
    }

    @objc public func resetStoreKitPresentationState() {
        self.isStoreKitViewBeingPresented = false
    }

    static func canLoadStoreKitProductWithAAK(parameters: [String: Any]) -> Bool {
        !containsData(parameters)
    }

    private static func containsData(_ value: Any) -> Bool {
        if value is Data { return true }
        if let array = value as? [Any] {
            return array.contains(where: containsData)
        }
        if let dictionary = value as? [AnyHashable: Any] {
            return dictionary.values.contains(where: containsData)
        }
        return false
    }
}

// MARK: - Helpers
extension HyBidSKAdNetworkViewController {
    
    @objc(isAutoStorekitEnabledForAd:)
    static public func isAutoStorekitEnabledForAd(ad: HyBidAd) -> Bool {
        
        guard ad.sdkAutoStorekitEnabled != nil, ad.sdkAutoStorekitEnabled.intValue >= 0, ad.sdkAutoStorekitEnabled.boolValue else {
            return HyBidConstants.sdkAutoStorekitEnabled
        }
        
        return true;
    }
    
    @objc static public func getStorekitAutoCloseDelay(ad: HyBidAd) -> Int {
        
        guard let sdkAutoStorekitDelay = ad.sdkAutoStorekitDelay else { return STOREKIT_DELAY_DEFAULT_VALUE }
        let autoStoreKitDelay = sdkAutoStorekitDelay.intValue
        guard autoStoreKitDelay >= 0 && sdkAutoStorekitDelay.stringValue.isNumber else { return STOREKIT_DELAY_DEFAULT_VALUE }
        
        guard (STOREKIT_DELAY_MINIMUM_VALUE...STOREKIT_DELAY_MAXIMUM_VALUE).contains(autoStoreKitDelay) else {
            return autoStoreKitDelay < STOREKIT_DELAY_MINIMUM_VALUE ? STOREKIT_DELAY_MINIMUM_VALUE : STOREKIT_DELAY_MAXIMUM_VALUE
        }
        
        return autoStoreKitDelay
    }
}

extension HyBidSKAdNetworkViewController: SKStoreProductViewControllerDelegate {
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        self.isStoreKitViewPresented = false
        self.isStoreKitViewBeingPresented = false

        if !HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled {
            HyBidInterruptionHandler.shared.productViewControllerDidFinish()
            HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled = true
        }
    }
}

extension SKStoreProductViewController {

    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        let transitionDuration = self.transitionCoordinator?.transitionDuration ?? HyBidStoreProductHelper.transitionDuration
        HyBidStoreProductHelper.presentedViewControllerHasBeenFalse = (self.presentedViewController != nil) ? false : true

        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration, execute: { [weak self] in
            guard let self else { return }
            if self.presentedViewController == nil && !HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled && !HyBidStoreProductHelper.presentedViewControllerHasBeenFalse {
                HyBidInterruptionHandler.shared.productViewControllerDidFinish()
                HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled = true
            }
        })
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled {
            HyBidInterruptionHandler.shared.productViewControllerDidFinish()
            HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled = true
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if #available(iOS 17.2, *) {
            self.loadProduct(withParameters: productParametersGlobal, completionBlock: nil)
        }
    }
}
