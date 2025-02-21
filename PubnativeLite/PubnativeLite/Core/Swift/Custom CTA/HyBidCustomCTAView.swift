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

private enum HyBidCustomCTAViewConstraintType {
    case rightAnchor
    case bottomAnchor
}

private let customCTAIntValidRange = (1...9)

@objc
public class HyBidCustomCTAView: UIView {
    
    // MARK: - Outlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var ctaActionButton: UIButton!
    @IBOutlet private weak var ctaIconImageView: UIImageView!
    
    //MARK: - Variables
    private let ctaNibName = "HyBidCustomCTAView"
    private let ctaAccessibilityLabel = "HyBidCustomCTAView"
    private let ctaIconAccessibilityLabel = "HyBidCustomCTAIcon"
    private let customCtaDelayDefaultValue = 2
    private let customCtaDelayMinValue = 0
    private let customCtaDelayMaxValue = 10
    private let customCTAWidth = 187
    private let customCTAHeight = 62
    private let ctaBackgroundColor: UIColor = .black.withAlphaComponent(0.5)
    private let elementsCornerRadius = 5.0
    private let ctaCornerRadius = 10.0
    private let ctaRightPadding = 6.0
    private var ctaBottomPadding = 0.0
    private let ctaBottomPaddingPercentage = 0.10
    private var ctaBottomConstraint = NSLayoutConstraint()
    private var ctaRightConstraint = NSLayoutConstraint()
    private var topViewController: UIViewController?
    private weak var delayTimer: Timer?
    private var remainingSecondsToShow = 0
    private var elementsBlockingAdFocus = 0
    private var iconURL: URL?
    private var isIconError = false
    private weak var delegate: HyBidCustomCTAViewDelegate?
    private var isCustomCTAAdded = false
    private var ad: HyBidAd?
    private var adFormat: String? = nil

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable)
    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: self.customCTAWidth, height: self.customCTAHeight)))
    }
    
    @objc public init(ad: HyBidAd, viewController: UIViewController, delegate:HyBidCustomCTAViewDelegate, adFormat: String) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: self.customCTAWidth, height: self.customCTAHeight)))
        self.ad = ad
        self.topViewController = viewController
        self.delegate = delegate
        self.adFormat = adFormat
        guard self.isCustomCTAValidToShow(ad: ad) else { return }
        self.iconURL = URL(string: ad.customCtaIconURL)
        self.remainingSecondsToShow = self.getSecondsDelay(ad: ad)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.xibSetUp()
            self.setUpUI()
        }
        
        self.setIconImage { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let icon):
                DispatchQueue.main.async { [weak self] in
                    self?.ctaIconImageView.image = icon
                }
                self.delegate?.customCTADidLoad(withSuccess: true)
            case .failure(let failure):
                self.isIconError = true
                self.delegate?.customCTADidLoad(withSuccess: false)
                HyBidLogger.errorLog(fromClass: NSStringFromClass(HyBidCustomCTAView.self), fromMethod: #function, withMessage: failure.localizedDescription)
            }
        }
    }
    
    private func moveFromLeftToRight() {
        guard let topViewController else { return }
        if !topViewController.view.subviews.filter({ type(of: $0) == HyBidCustomCTAView.self }).isEmpty || self.isIconError {
            return
        }
        
        topViewController.view.addSubview(self)
        isCustomCTAAdded = true
        ctaBottomPadding = calculateBottomConstantConstraint(topViewController: topViewController)
        
        setPositionConstraint(type: .rightAnchor, viewController: topViewController, constant: self.frame.size.width)
        setPositionConstraint(type: .bottomAnchor, viewController: topViewController, constant: ctaBottomPadding)
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.setPositionConstraint(type: .rightAnchor, viewController: topViewController, constant: -self.ctaRightPadding)
            
            guard let adFormat = self.adFormat else { return }
            if HyBidSDKConfig.sharedConfig.reporting == true {
                let reportingEvent = HyBidReportingEvent(with: EventType.CUSTOM_CTA_IMPRESSION, adFormat: adFormat, properties: nil)
                HyBid.reportingManager().reportEvent(for: reportingEvent)
            }
            self.delegate?.customCTADidShow()
        }
    }
    
    private func setPositionConstraint(type: HyBidCustomCTAViewConstraintType, viewController: UIViewController, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        switch type {
        case .rightAnchor:
            viewController.view.removeConstraint(ctaRightConstraint)
            if #available(iOS 11.0, *) {
                ctaRightConstraint = self.rightAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.rightAnchor, constant: constant)
            } else {
                ctaRightConstraint = self.rightAnchor.constraint(equalTo: viewController.view.rightAnchor, constant: constant)
            }
            viewController.view.addConstraint(ctaRightConstraint)
        case .bottomAnchor:
            viewController.view.removeConstraint(ctaBottomConstraint)
            if #available(iOS 11.0, *) {
                ctaBottomConstraint = self.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: constant)
            } else {
                ctaBottomConstraint = self.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: constant)
            }
            viewController.view.addConstraint(ctaBottomConstraint)
        }
        viewController.view.layoutIfNeeded()
    }
    
    private func calculateBottomConstantConstraint(topViewController: UIViewController) -> CGFloat {
        if #available(iOS 11.0, *) {
            return -topViewController.view.safeAreaLayoutGuide.layoutFrame.size.height * ctaBottomPaddingPercentage
        } else {
            return -topViewController.view.frame.size.height * ctaBottomPaddingPercentage
        }
    }
    
    private func updateCustomCTATimer(state: HyBidTimerState) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.remainingSecondsToShow <= 0 {
                self.moveFromLeftToRight()
                return;
            }
            
            switch state {
            case .start:
                guard self.remainingSecondsToShow != -1, self.delayTimer == nil else { return }
                
                self.delayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    guard let self else { return }
                    if self.remainingSecondsToShow <= 0 {
                        self.moveFromLeftToRight()
                        self.invalidateTimer()
                        NotificationCenter.default.removeObserver(self)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
                    }
                    self.remainingSecondsToShow -= 1
                }
            case .pause:
                self.invalidateTimer()
            case .stop:
                self.remainingSecondsToShow = -1
                self.invalidateTimer()
            @unknown default:
                break
            }
        }
    }
    
    private func invalidateTimer(){
        self.delayTimer?.invalidate()
        self.delayTimer = nil
    }
    
    private func isCustomCTAValidToShow(ad: HyBidAd) -> Bool {
        guard HyBidCustomCTAView.isCustomCTAValid(ad: ad),
              URL(string: ad.customCtaIconURL) != nil,
              !self.isIconError else { return false }
        
        return true
    }
    
    private func getSecondsDelay(ad: HyBidAd) -> Int {
        guard let customCtaDelayValue = ad.customCtaDelay else { return customCtaDelayDefaultValue}
        
        let numberformatter = NumberFormatter()
        numberformatter.decimalSeparator = "."
        guard let customCtaDelayNumber = numberformatter.number(from: customCtaDelayValue.stringValue) else {
            return customCtaDelayDefaultValue
        }
        
        let customCtaDelay = customCtaDelayNumber.intValue > customCtaDelayMaxValue ? customCtaDelayMaxValue : customCtaDelayNumber.intValue
        guard (customCtaDelayMinValue...customCtaDelayMaxValue).contains(customCtaDelay) else {
            return customCtaDelayDefaultValue
        }
        return customCtaDelay
    }
    
    @IBAction func openOffer() {
        self.delegate?.customCTADidClick()
    }
}

//MARK: - Custom CTA Public methods
extension HyBidCustomCTAView {
    @objc public func presentCustomCTAWithDelay() {
        guard let ad, self.isCustomCTAValidToShow(ad: ad) else { return }
        addObservers()
        updateCustomCTATimer(state: .start)
    }

    @objc public func removeCustomCTA() {
        NotificationCenter.default.removeObserver(self)
        self.invalidateTimer()
        self.removeFromSuperview()
    }
    
    @objc(changeDelegateFor:)
    public func changeDelegate(delegate: HyBidCustomCTAViewDelegate) {
        self.delegate = delegate
    }
    
    @objc static public func isCustomCTAValid(ad: HyBidAd) -> Bool {
        guard ad.skoverlayEnabled == nil || 
              (ad.skoverlayEnabled != nil &&
              ad.skoverlayEnabled.boolValue == false) ||
              (ad.isUsingOpenRTB ? ad.getOpenRTBSkAdNetworkModel() : ad.getSkAdNetworkModel()) == nil ||
              HyBidSKOverlay.isValidToCreateSKOverlay(with: ad.isUsingOpenRTB ? ad.getOpenRTBSkAdNetworkModel() : ad.getSkAdNetworkModel()) == false else { return false }
        
        guard ad.customCtaEnabled != nil,
              HyBidCustomCTAView.isCustomCTAEnable(ad: ad),
              ad.customCtaIconURL != nil,
              URL(string: ad.customCtaIconURL) != nil else { return false }
        
        return true
    }
    
    static private func isCustomCTAEnable(ad: HyBidAd) -> Bool {
        let numberformatter = NumberFormatter()
        numberformatter.decimalSeparator = "."
        if let isNumeric = numberformatter.number(from: ad.customCtaEnabled.stringValue) {
            return customCTAIntValidRange.contains(isNumeric.intValue)
        }
        
        return ad.customCtaEnabled.boolValue
    }
}

//MARK: - Custom CTA UI
extension HyBidCustomCTAView {
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: HyBidCustomCTAView.self)
        let nib = UINib(nibName: ctaNibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return nil }
        return view
    }
    
    private func xibSetUp() {
        if let nibView = loadViewFromNib() {
            contentView = nibView
            contentView.frame = self.bounds
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.openOffer))
            self.addGestureRecognizer(gesture)
            addSubview(contentView)
            self.accessibilityIdentifier = self.ctaAccessibilityLabel
            self.ctaIconImageView.accessibilityIdentifier = self.ctaIconAccessibilityLabel
        }
    }
    
    private func setUpUI() {
        contentView.backgroundColor = ctaBackgroundColor
        setCornerRadius(view: self, cornerRadius: ctaCornerRadius)
        setCornerRadius(view: ctaActionButton, cornerRadius: elementsCornerRadius)
        setCornerRadius(view: ctaIconImageView, cornerRadius: elementsCornerRadius)
        let localizedButtonTitle = HyBidLocalization.customCTAButtonTitle.localized()
        ctaActionButton.setTitle(localizedButtonTitle.uppercased(), for: .normal)
        ctaActionButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func setCornerRadius(view: UIView, cornerRadius: CGFloat) {
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
    }
    
    @objc private func orientationDidChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isCustomCTAAdded, let topViewController = self.topViewController else { return }
            self.ctaBottomPadding = self.calculateBottomConstantConstraint(topViewController: topViewController)
            self.setPositionConstraint(type: .bottomAnchor, viewController: topViewController, constant: self.ctaBottomPadding)
        }
    }
}

//MARK: - Custom CTA data
extension HyBidCustomCTAView {
    
    private func setIconImage(completion: @escaping (Result<UIImage, Error>) -> ()) {
        DispatchQueue.global().async { [weak self] in
            do {
                guard let url = self?.iconURL else { throw NSError.hyBidInvalidCustomCTAIconUrl() }
                let data = try Data(contentsOf: url)
                guard let icon = UIImage(data: data) else { throw NSError.hyBidInvalidCustomCTAIconUrl() }
                completion(.success(icon))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

//MARK: - Observers
extension HyBidCustomCTAView {
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adHasNotFocus),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        HyBidNotificationCenter.shared.addObserver(self, selector: #selector(adHasNotFocus),
                                                   notificationType: .AdFeedbackViewDidShow,
                                                   object: nil)
        HyBidNotificationCenter.shared.addObserver(self, selector: #selector(adHasNotFocus),
                                                   notificationType: .SKStoreProductViewIsShown,
                                                   object: nil)
        HyBidNotificationCenter.shared.addObserver(self, selector: #selector(adHasNotFocus),
                                                   notificationType: .InternalWebBrowserDidShow,
                                                   object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(adMayHaveFocus),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        HyBidNotificationCenter.shared.addObserver(self, selector: #selector(adMayHaveFocus),
                                                   notificationType: .AdFeedbackViewIsDismissed,
                                                   object: nil)
        HyBidNotificationCenter.shared.addObserver(self, selector: #selector(adMayHaveFocus),
                                                   notificationType: .SKStoreProductViewIsDismissed,
                                                   object: nil)
        HyBidNotificationCenter.shared.addObserver(self, selector: #selector(adMayHaveFocus),
                                                   notificationType: .InternalWebBrowserDidDismissed,
                                                   object: nil)

    }
    
    @objc private func adHasNotFocus() {
        updateCustomCTATimer(state: .pause)
        elementsBlockingAdFocus += 1
    }
    
    @objc private func adMayHaveFocus() {
        elementsBlockingAdFocus -= 1
        if elementsBlockingAdFocus == 0 {
            updateCustomCTATimer(state: .start)
        }
    }
}
