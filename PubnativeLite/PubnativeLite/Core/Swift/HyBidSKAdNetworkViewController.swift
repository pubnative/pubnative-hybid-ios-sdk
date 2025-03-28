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

private enum HyBidOverrideOptionsType {
    case superClassOption
    case presentingViewControllerOption
    case customImplementationOption
}

private var productParametersGlobal: Dictionary<String,Any> = [:]

@objc
public class HyBidSKAdNetworkViewController: NSObject {
    
    @objc public static let shared = HyBidSKAdNetworkViewController()
    public var isSKPVCViewPresented = false
    private var skStoreProductViewController = SKStoreProductViewController()
    
    @objc public func presentSKStoreProductViewController(productParameters: Dictionary<String,Any>,
                                                          adFormat: String,
                                                          isAutoSKPVC: Bool) {
        guard !productParameters.isEmpty else { return }
        self.skStoreProductViewController = SKStoreProductViewController()
        productParametersGlobal = productParameters
        self.skStoreProductViewController.delegate = HyBidInterruptionHandler.shared
        HyBidInterruptionHandler.shared.productViewControllerWillShow()
        self.skStoreProductViewController.loadProduct(withParameters: productParameters) { success, error in
#if !targetEnvironment(simulator)
            guard error == nil, success == true else {
                HyBidLogger.errorLog(fromClass: String(describing: HyBidSKAdNetworkViewController.self), fromMethod: #function, withMessage: "Loading the ad failed, try to load another ad or retry the current ad.")
                self.isSKPVCViewPresented = false
                if let error { HyBidInterruptionHandler.shared.productViewControllerDidFail(error: error) }
                return
            }
#endif
            DispatchQueue.main.async { [weak self] in
                guard let self, self.isSKPVCViewPresented == false else {
                    HyBidLogger.infoLog(fromClass: String(describing: HyBidSKAdNetworkViewController.self), fromMethod: #function, withMessage: "Suppressing an attempt to manual/auto click when task is not finished yet")
                    return
                }
                HyBidInterruptionHandler.shared.productViewControllerIsReadyToShow()
                self.isSKPVCViewPresented = true
                UIApplication.shared.topViewController.present(self.skStoreProductViewController, animated: true) {
                    HyBidInterruptionHandler.shared.productViewControllerDidShow(isAutoSKPVC: isAutoSKPVC, adFormat: adFormat)
                }
            }
        }
    }
    
    @objc public func isSKProductViewControllerPresented() -> Bool {
        return self.isSKPVCViewPresented
    }
}

extension SKStoreProductViewController {
    
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
