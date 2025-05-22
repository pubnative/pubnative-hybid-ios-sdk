// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

@objc
public class HyBidInternalWebBrowserNavigationController: UINavigationController {
    
    //-MARK: Variables
    @objc public static let shared = HyBidInternalWebBrowserNavigationController()
    private let storyboardName = "InternalWebBrowser"
    private let internalWebBrowserIdentifier = "HyBidInternalWebBrowserViewController"
    var isInternalBrowserBeingPresented: Bool = false
    
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
        self.isInternalBrowserBeingPresented = false
    }

    @objc public func navigateToURL(_ url: String) {
        guard let url = URL(string: url) else {
            return
        }

        guard url.scheme == "https" || url.scheme == "http" else { return UIApplication.shared.open(url) }
        if url.host == "apps.apple.com" { return UIApplication.shared.open(url) }
        
        guard self.isInternalBrowserBeingPresented == false else { return }
        
        self.isInternalBrowserBeingPresented = true
        self.setUpInternalBrowser(url: url)
        UIApplication.shared.topViewController.present(self, animated: true)
    }
    
    @objc public func webBrowserNavigationBehaviourFromString(_ value: String?) -> HyBidWebBrowserNavigation {
        guard let navigationValue: String = value, navigationValue == HyBidWebBrowserNavigationInternalValue else {
            return HyBidWebBrowserNavigationExternal
        }
        
        return HyBidWebBrowserNavigationInternal
    }
}
