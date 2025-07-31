// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

@objc public class HyBidInternalWebBrowser: NSObject {
    
    @objc public static let shared = HyBidInternalWebBrowser()
    private var internalWebBrowserNavigationController: HyBidInternalWebBrowserNavigationController?
    @objc public var isInternalBrowserBeingPresented: Bool = false
    
    @objc public func navigateToURL(_ url: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.internalWebBrowserNavigationController = self.internalWebBrowserNavigationController ?? HyBidInternalWebBrowserNavigationController()
            self.internalWebBrowserNavigationController?.navigateToURL(url)
        }
    }
    
    @objc public func webBrowserNavigationBehaviourFromString(_ value: String?) -> HyBidWebBrowserNavigation {
        guard let navigationValue: String = value, navigationValue == HyBidWebBrowserNavigationInternalValue else {
            return HyBidWebBrowserNavigationExternal
        }
        
        return HyBidWebBrowserNavigationInternal
    }
}

fileprivate class HyBidInternalWebBrowserNavigationController: UINavigationController {
    
    //-MARK: Variables
    private let storyboardName = "InternalWebBrowser"
    private let internalWebBrowserIdentifier = "HyBidInternalWebBrowserViewController"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUpInternalBrowser(url: URL){
        let bundle = Bundle(for: HyBidInternalWebBrowserNavigationController.self)
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: bundle)
        guard let internalWebBrowserViewController = storyboard.instantiateViewController(withIdentifier: internalWebBrowserIdentifier) as? HyBidInternalWebBrowserViewController else {
            return
        }
        internalWebBrowserViewController.setURLToNavigate(url)
        self.viewControllers = [internalWebBrowserViewController]
        self.modalPresentationStyle = .fullScreen
        self.setToolbarHidden(false, animated: false)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        HyBidInternalWebBrowser.shared.isInternalBrowserBeingPresented = false
    }

    fileprivate func navigateToURL(_ url: String) {
        guard let url = URL(string: url) else {
            return
        }

        guard url.scheme == "https" || url.scheme == "http" else { return UIApplication.shared.open(url) }
        if url.host == "apps.apple.com" { return UIApplication.shared.open(url) }
        
        guard HyBidInternalWebBrowser.shared.isInternalBrowserBeingPresented == false else { return }
        
        HyBidInternalWebBrowser.shared.isInternalBrowserBeingPresented = true
        self.setUpInternalBrowser(url: url)
        UIApplication.shared.topViewController.present(self, animated: true)
    }
}
