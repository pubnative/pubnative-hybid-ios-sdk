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
    
    private func setUpInternalBrowser(url: URL, delegate: HyBidInternalWebBrowserDelegate){
        let bundle = Bundle(for: HyBidInternalWebBrowserNavigationController.self)
        let storyboard : UIStoryboard = UIStoryboard(name: storyboardName, bundle: bundle)
        guard let internalWebBrowserViewController = storyboard.instantiateViewController(withIdentifier: internalWebBrowserIdentifier) as? HyBidInternalWebBrowserViewController else {
            delegate.internalWebBrowserDidFail?()
            return
        }
        internalWebBrowserViewController.setURLToNavigate(url)
        internalWebBrowserViewController.setDelegate(delegate)
        self.viewControllers = [internalWebBrowserViewController]
        self.modalPresentationStyle = .fullScreen
        self.setToolbarHidden(false, animated: false)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isInternalBrowserBeingPresented = false
    }

    @objc public func navigateToURL(_ url: String, delegate: HyBidInternalWebBrowserDelegate) {
        guard let url = URL(string: url) else {
            delegate.internalWebBrowserDidFail?()
            return
        }

        guard url.scheme == "https" || url.scheme == "http" else { return UIApplication.shared.open(url) }
        if url.host == "apps.apple.com" { return UIApplication.shared.open(url) }
        
        guard self.isInternalBrowserBeingPresented == false else { return }
        
        self.isInternalBrowserBeingPresented = true
        self.setUpInternalBrowser(url: url, delegate: delegate)
        delegate.internalWebBrowserWillShow?()
        UIApplication.shared.topViewController.present(self, animated: true)
    }
    
    @objc public func webBrowserNavigationBehaviourFromString(_ value: String?) -> HyBidWebBrowserNavigation {
        guard let navigationValue: String = value, navigationValue == HyBidWebBrowserNavigationInternalValue else {
            return HyBidWebBrowserNavigationExternal
        }
        
        return HyBidWebBrowserNavigationInternal
    }
}
