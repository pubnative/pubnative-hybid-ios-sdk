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
import AppLovinSDK

class HyBidDemoALNativeViewController: PNLiteDemoBaseViewController {
    
    @IBOutlet weak private var appLovinNativeAdContainerView: MANativeAdView!
    @IBOutlet weak private var nativeAdLoaderIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var debugButton: UIButton!
    
    private let appLovinNativeViewNibName = "HyBidDemoAppLovinNativeView"
    private let appLovinNativeAdLoader: MANativeAdLoader = MANativeAdLoader(adUnitIdentifier: UserDefaults.standard.string(forKey: kHyBidALMediationNativeAdUnitIDKey) ?? "")
    private var appLovinNativeAdView: MANativeAdView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "AppLovin Mediation Native"
        nativeAdLoaderIndicator.stopAnimating()
        debugButton.isHidden = true
        appLovinNativeAdContainerView.backgroundColor = .clear
        let appLovinNativeAdViewNib = UINib(nibName: appLovinNativeViewNibName, bundle: .main)
        guard let appLovinNativeAdView = appLovinNativeAdViewNib.instantiate(withOwner: nil, options: nil).first as? MANativeAdView? else { return }
        self.appLovinNativeAdView = appLovinNativeAdView
        
        let adViewBinder = MANativeAdViewBinder.init(builderBlock: { (builder) in
            builder.titleLabelTag = 1001
            builder.advertiserLabelTag = 1002
            builder.bodyLabelTag = 1003
            builder.iconImageViewTag = 1004
            builder.optionsContentViewTag = 1005
            builder.mediaContentViewTag = 1006
            builder.callToActionButtonTag = 1007
        })
        appLovinNativeAdView?.bindViews(with: adViewBinder)
        appLovinNativeAdLoader.nativeAdDelegate = self
    }
    
    @IBAction private func loadAd() {
        requestAd()
    }
    
    override func requestAd() {
        self.clearDebugTools()
        appLovinNativeAdContainerView.isHidden = true
        debugButton.isHidden = true
        nativeAdLoaderIndicator.startAnimating()
        appLovinNativeAdLoader.loadAd(into: appLovinNativeAdView)
    }
}

extension HyBidDemoALNativeViewController: MANativeAdDelegate {
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        if let adView = nativeAdView {
            appLovinNativeAdView.removeFromSuperview()
            appLovinNativeAdView = adView
            appLovinNativeAdView.frame = appLovinNativeAdContainerView.bounds
            appLovinNativeAdContainerView.addSubview(adView)
            
            appLovinNativeAdView.titleLabel = adView.titleLabel
            appLovinNativeAdView.bodyLabel = adView.bodyLabel
            appLovinNativeAdView.callToActionButton = adView.callToActionButton
            adView.callToActionButton?.isUserInteractionEnabled = false
            appLovinNativeAdView.iconImageView = adView.iconImageView
            appLovinNativeAdView.mediaContentView = adView.mediaContentView
            appLovinNativeAdView.optionsContentView = adView.optionsContentView
            appLovinNativeAdView.advertiserLabel = adView.advertiserLabel
        }
        nativeAdLoaderIndicator.stopAnimating()
        debugButton.isHidden = false
        appLovinNativeAdContainerView.isHidden = false
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        debugButton.isHidden = false
        nativeAdLoaderIndicator.stopAnimating()
        self.showAlert(withMessage: "AppLovin Native did fail to load with message: \(error.message), description: \(String(describing: error.adLoadFailureInfo))")
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        print("didClickAd")
    }
}
