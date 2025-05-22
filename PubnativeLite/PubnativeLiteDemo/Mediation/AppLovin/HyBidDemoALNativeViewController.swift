// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
