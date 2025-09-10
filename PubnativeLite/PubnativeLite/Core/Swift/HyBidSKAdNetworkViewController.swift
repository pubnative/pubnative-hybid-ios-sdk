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
    private var skStoreProductViewController : SKStoreProductViewController?
    private var ad: HyBidAd?
    @objc public var avoidAutoStoreKitPresentationAfterReplay = false
    private var rootViewController : UIViewController? = .none
    
    @available(iOS 17.4, *)
    private func loadStoreKitViewAAK(parameters: [String : Any], adFormat: String, isAutoStoreKitView: Bool) async {
        guard let ad, let impression = await HyBidAdAttributionManager.getAppImpression(ad: ad, adFormat: adFormat, aakAdType: isAutoStoreKitView ? .autoStoreKitView : .storeKitView) else {
            return self.loadStoreKitView(parameters: parameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView)
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
                self.presentStoreKitViewOnTopViewController(handlerController: self, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView)
            }
        } catch {
            _ = self.isStoreKitViewResultSuccessful(error: error)
        }
    }
    
    private func loadStoreKitView(parameters: [String : Any], adFormat: String, isAutoStoreKitView: Bool) {
        self.skStoreProductViewController?.loadProduct(withParameters: parameters) { success, error in
#if !targetEnvironment(simulator)
            guard self.isStoreKitViewResultSuccessful(error: error, success: success) else { return }
#endif
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.presentStoreKitViewOnTopViewController(handlerController: self, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView)
            }
        }
    }
    
    private func presentStoreKitViewOnTopViewController(handlerController: HyBidSKAdNetworkViewController?,
                                                 adFormat: String,
                                                 isAutoStoreKitView: Bool) {
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
        
        HyBidInterruptionHandler.shared.productViewControllerIsReadyToShow()
        handlerController.isStoreKitViewPresented = true
        guard let skStoreProductViewController = handlerController.skStoreProductViewController else { return }
        guard let presentationViewController = self.rootViewController ?? UIApplication.shared.topViewController else { return }
        presentationViewController.present(skStoreProductViewController, animated: true) {
            handlerController.isStoreKitViewPresented = true
            handlerController.rootViewController = nil
            HyBidInterruptionHandler.shared.productViewControllerDidShow(isAutoStoreKitView: isAutoStoreKitView, adFormat: adFormat)
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
        self.rootViewController = rootViewController
        self.presentStoreKitView(productParameters: productParameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView, ad: ad)
    }
    
    @objc public func presentStoreKitView(productParameters: Dictionary<String,Any>, adFormat: String,
                                          isAutoStoreKitView: Bool, ad:HyBidAd) {
        guard !productParameters.isEmpty else { return }
        productParametersGlobal = productParameters
        self.ad = ad
        
        DispatchQueue.main.async {
            self.skStoreProductViewController = SKStoreProductViewController()
            self.skStoreProductViewController?.delegate = self
            HyBidInterruptionHandler.shared.productViewControllerWillShow()

            if #available(iOS 17.4, *) {
                Task { [weak self] in
                    guard let self else { return }
                    await self.loadStoreKitViewAAK(parameters: productParameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView)
                }
            } else {
                DispatchQueue.global().async {
                    self.loadStoreKitView(parameters: productParameters, adFormat: adFormat, isAutoStoreKitView: isAutoStoreKitView)
                }
            }
        }
    }
    
    @objc public func isSKProductViewControllerPresented() -> Bool {
        return self.isStoreKitViewPresented
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
        if !HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled {
            HyBidInterruptionHandler.shared.productViewControllerDidFinish()
            HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled = true
        }
    }
}

extension SKStoreProductViewController {

    private enum HyBidOverrideOptionsType {
        case superClassOption
        case presentingViewControllerOption
        case customImplementationOption
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HyBidStoreProductHelper.productViewControllerDidFinishHasBeenCalled = false
    }
    
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
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let overrideOption = hyBidDetermineOverrideOption(with: self.presentingViewController, selector: #selector(getter: self.supportedInterfaceOrientations))
        switch overrideOption {
        case .superClassOption:
            return super.supportedInterfaceOrientations
        case .presentingViewControllerOption:
            return self.presentingViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
        case .customImplementationOption:
            return .all
        }
    }
    
    open override var shouldAutorotate: Bool {
        let overrideOption = hyBidDetermineOverrideOption(with: presentingViewController, selector: #selector(getter: self.shouldAutorotate))
        switch overrideOption {
        case .superClassOption:
            return super.shouldAutorotate
        case .presentingViewControllerOption:
            return presentingViewController?.shouldAutorotate ?? super.shouldAutorotate
        case .customImplementationOption:
            let applicationSupportedOrientations = UIApplication.shared.supportedInterfaceOrientations(for: UIApplication.shared.keyWindow)
            let viewControllerSupportedOrientations = supportedInterfaceOrientations
            return viewControllerSupportedOrientations.intersection(applicationSupportedOrientations).rawValue != 0
        }
    }
    
    private func hyBidDetermineOverrideOption(with presentingViewController: UIViewController?, selector: Selector) -> HyBidOverrideOptionsType {
        
        guard let presentingViewController = presentingViewController else { return .superClassOption }
        guard let presentingVCBundleID = Bundle(for: type(of: presentingViewController)).bundleIdentifier else {
            return .superClassOption
        }
        
        guard let hyBidBundleID = Bundle(for: HyBidSKAdNetworkViewController.self).bundleIdentifier else {
            return .superClassOption
        }
        
        if presentingVCBundleID != hyBidBundleID {
            return doesClassHasMethod(cls: type(of: presentingViewController), sel: selector)
            ? .presentingViewControllerOption
            : .superClassOption
        }
        
        return .customImplementationOption
    }
    
    private func doesClassHasMethod(cls: AnyClass, sel: Selector) -> Bool {
        var methodCount: UInt32 = 0
        guard let methods = class_copyMethodList(cls, &methodCount) else { return false }
        
        var result = false
        for i in 0..<Int(methodCount) {
            if method_getName(methods[i]) == sel {
                result = true
                break
            }
        }
        
        free(methods)
        return result
    }
}
