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
import WebKit

class HyBidInternalWebBrowserViewController: UIViewController {
    
    //-MARK: Outlets
    @IBOutlet weak var internalWebView: WKWebView!
    @IBOutlet weak var internalWebBrowserProgressView: UIProgressView!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var reloadBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var goingBackBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var goingForwardBarButtonItem: UIBarButtonItem!
    
    //-MARK: Variables
    private var url: URL?
    private var delegate: HyBidInternalWebBrowserDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInternalWebView()
        self.setInternalWebBrowserProgressView()
        self.setAccessibilityIdentifiers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.internalWebBrowserDidShow?()
        HyBidNotificationCenter.shared.post(.InternalWebBrowserDidShow)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        internalWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    private func setInternalWebView(){
        guard let url else { return }
        internalWebView.load(URLRequest(url: url))
        internalWebView.navigationDelegate = self
        internalWebView.uiDelegate = self
        internalWebView.allowsBackForwardNavigationGestures = true
        internalWebView.allowsLinkPreview = false
        if #available(iOS 16.4, *) { internalWebView.isInspectable = true }
        
    }
    
    private func setInternalWebBrowserProgressView(){
        internalWebBrowserProgressView.progress = Float(internalWebView.estimatedProgress)
        internalWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress),options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            self.internalWebBrowserProgressView.progress = Float(internalWebView.estimatedProgress)
            self.internalWebBrowserProgressView.isHidden = Float(internalWebView.estimatedProgress) < 1 ? false : true
        }
    }
    
    func setURLToNavigate(_ url: URL) {
        self.url = url
    }
    
    func setDelegate(_ delegate: HyBidInternalWebBrowserDelegate) {
        self.delegate = delegate
    }
    
    private func setAccessibilityIdentifiers() {
        internalWebView.accessibilityIdentifier = "Internal web browser"
        internalWebView.accessibilityLabel = "Internal web browser"
        
        internalWebBrowserProgressView.accessibilityIdentifier = "Progress view internal web browser"
        internalWebBrowserProgressView.accessibilityLabel = "Progress view internal web browser"
        
        doneBarButtonItem.accessibilityIdentifier = "Done button internal web browser"
        doneBarButtonItem.accessibilityLabel = "Done button internal web browser"
        
        reloadBarButtonItem.accessibilityIdentifier = "Reload button internal web browser"
        reloadBarButtonItem.accessibilityLabel = "Reload button internal web browser"
        
        goingBackBarButtonItem.accessibilityIdentifier = "Going back button internal web browser"
        goingBackBarButtonItem.accessibilityLabel = "Going back button internal web browser"
        
        goingForwardBarButtonItem.accessibilityIdentifier = "Going forward button internal web browser"
        goingForwardBarButtonItem.accessibilityLabel = "Going forward button internal web browser"
    }
    
    @IBAction private func dismissInternalWebBrowser(_ sender: Any) {
        self.delegate?.internalWebBrowserWillDismiss?()
        guard let navigationController = self.navigationController else {
            return self.dismiss(animated: true) {
                HyBidInternalWebBrowserNavigationController.shared.isInternalBrowserBeingPresented = false
                self.delegate?.internalWebBrowserDidDismiss?()
                HyBidNotificationCenter.shared.post(.InternalWebBrowserDidDismissed)
            }
        }
        navigationController.dismiss(animated: true) {
            self.delegate?.internalWebBrowserDidDismiss?()
            HyBidNotificationCenter.shared.post(.InternalWebBrowserDidDismissed)
        }
    }
    
    @IBAction private func reloadInternalWebView(_ sender: Any) {
        internalWebView.reload()
    }
    
    @IBAction private func internalWebViewGoingBack(_ sender: Any) {
        if internalWebView.canGoBack { internalWebView.goBack() }
    }
    
    @IBAction private func internalWebViewGoingForward(_ sender: Any) {
        if internalWebView.canGoForward { internalWebView.goForward() }
    }
}

// - MARK: WKNavigationDelegate
extension HyBidInternalWebBrowserViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        
        switch navigationAction.navigationType {
        case .linkActivated:
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
        case .formSubmitted, .backForward, .reload, .formResubmitted:
            decisionHandler(.allow)
        case .other:
            guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
            guard url.scheme == "https" || url.scheme == "http" else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
                break
            }
            
            if url.host == "apps.apple.com" { UIApplication.shared.open(url) }
            decisionHandler(.allow)
        @unknown default:
            decisionHandler(.allow)
        }
    }
}

// - MARK: WKUIDelegate
extension HyBidInternalWebBrowserViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        guard let url = navigationAction.request.url else { return .none }
        internalWebView.load(URLRequest(url: url))
        return .none
    }
}
