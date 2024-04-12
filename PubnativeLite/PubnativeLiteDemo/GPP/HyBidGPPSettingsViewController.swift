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
// FIXME: Replace OneTrust with UserCentrics
//import OTPublishersHeadlessSDK
import HyBid

// MARK: - Enums and Protocols

enum GPPDataType: Int {
    case gppInternalString = 0
    case gppInternalSID = 1
    case gppInternalData = 2
    case gppPublicString
    case gppPublicSID
    case gppData
}

enum HyBidGPPSDKState {
    case noInitialized
    case loading
    case initialized
    case error
}
protocol HyBidGPPSDKInitializerDelegate: AnyObject {
    func sdkDidInitialized()
    func sdkDidFail(error: Error)
}

@objc public class HyBidGPPSDKInitializer: NSObject {
    
    static private var oneTrustSDKState = HyBidGPPSDKState.noInitialized
    static private let mobile_app_ID = "8e33c129-9326-49a7-9994-9f61a5ba7e7d-test"
    static private let storageLocation = "cdn.cookielaw.org"
    static var delegate: HyBidGPPSDKInitializerDelegate? = nil
    
    static func sdkState() -> HyBidGPPSDKState {
        return self.oneTrustSDKState
    }
    
    @objc static func retryInitOneTrustSDK(){
        oneTrustSDKState = .noInitialized
// FIXME: Replace OneTrust with UserCentrics
//        initOneTrustSDK()
    }
    
    @objc static func initOneTrustSDK(){
// FIXME: Replace OneTrust with UserCentrics
       /*
        if HyBidGPPSDKInitializer.sdkState() == .noInitialized {
            oneTrustSDKState = .loading
            OTPublishersHeadlessSDK.shared.startSDK(storageLocation: storageLocation, domainIdentifier: mobile_app_ID, languageCode: "en") { response  in
                switch response.status {
                case true:
                    oneTrustSDKState = .initialized
                    delegate?.sdkDidInitialized()
                case false:
                    oneTrustSDKState = .error
                    guard let error = response.error else { return }
                    delegate?.sdkDidFail(error: error)
                }
            }
        }
        */
    }
}

class HyBidGPPSettingsViewController: UIViewController {
    
    // MARK: - Variables
    
    private let userDataManagerSharedInstance = HyBidUserDataManager.sharedInstance()
    private let gppStringDummyValue = "Dummy GPP String"
    private let gppSIDDummyValue = "2_4_5_6_7_8_9_15"
    private var waitingSDKInitAlert = UIAlertController()
    
    // MARK: - Outlets
    
    @IBOutlet weak private var publicGPPStringLabel: UILabel!
    @IBOutlet weak private var publicGPPSIDLabel: UILabel!
    @IBOutlet weak private var internalGPPStringLabel: UILabel!
    @IBOutlet weak private var internalGPPSIDLabel: UILabel!
    @IBOutlet weak private var gppInternalStringTextField: UITextField!
    @IBOutlet weak private var gppInternalSIDTextField: UITextField!
    
    @IBOutlet weak var publicGPPStringValue: UILabel!
    @IBOutlet weak var publicGPPSIDValue: UILabel!
    @IBOutlet weak var internalGPPSIDValue: UILabel!
    @IBOutlet weak var internalGPPStringValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: Replace OneTrust with UserCentrics
//        OTPublishersHeadlessSDK.shared.addEventListener(self)
        HyBidGPPSDKInitializer.delegate = self
        userDataManagerSharedInstance.delegate = self
        gppInternalStringTextField.addDismissKeyboardButton(withTitle: "Done", withTarget: self, with: #selector(doneButtonAction))
        gppInternalSIDTextField.addDismissKeyboardButton(withTitle: "Done", withTarget: self, with: #selector(doneButtonAction))
        // FIXME: Replace OneTrust with UserCentrics
//        configureView()
    }
    
    private func configureView(){
        switch HyBidGPPSDKInitializer.sdkState() {
        case .noInitialized, .loading:
            hiddeGPPLabels(hidde: true)
            showWaitingSDKAlert()
        case .initialized:
            hiddeGPPLabels(hidde: false)
            dismissWaitingSDKAlert()
        case .error:
            hiddeGPPLabels(hidde: true)
            showRetryInitSDKAlert()
        }
    }
    
    private func setOutletsValues (){
        DispatchQueue.main.async { [weak self] in
            if HyBidGPPSDKInitializer.sdkState() != .initialized { return }
            guard let self = self else { return }
                        
            self.publicGPPStringValue.text = "\(self.userDataManagerSharedInstance.getPublicGPPString() ?? "")"
            self.publicGPPStringValue.accessibilityValue = self.publicGPPStringValue.text;
            
            self.publicGPPSIDValue.text = "\(self.userDataManagerSharedInstance.getPublicGPPSID() ?? "")"
            self.publicGPPSIDValue.accessibilityValue = self.publicGPPSIDValue.text;

            self.internalGPPStringValue.text = "\(self.userDataManagerSharedInstance.getInternalGPPString() ?? "")"
            self.internalGPPStringValue.accessibilityValue = self.internalGPPStringValue.text;

            self.internalGPPSIDValue.text = "\(self.userDataManagerSharedInstance.getInternalGPPSID() ?? "")"
            self.internalGPPSIDValue.accessibilityValue = self.internalGPPSIDValue.text;
        }
    }
    
    private func setGPPData(type: Int, value: String? = nil){
        guard let gppType = GPPDataType(rawValue: type) else {
            return
        }
        
        setGPPData(type: gppType, value: value)
    }
    
    private func setGPPData(type: GPPDataType, value: String? = nil){
        switch type {
        case .gppInternalString:
            if let gppString = value, !gppString.isEmpty {
                userDataManagerSharedInstance.setInternalGPPString(gppString)
            } else {
                guard let gppString = gppInternalStringTextField.text, gppString.count != 0 else {
                    return
                }
                userDataManagerSharedInstance.setInternalGPPString(gppString)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.gppInternalStringTextField.text = ""
            }
        case .gppInternalSID:
            if let gppSID = value, !gppSID.isEmpty {
                userDataManagerSharedInstance.setInternalGPPSID(gppSID)
            } else {
                guard let gppSID = gppInternalSIDTextField.text, gppSID.count != 0 else {
                    return
                }
                userDataManagerSharedInstance.setInternalGPPSID(gppSID)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.gppInternalSIDTextField.text = ""
            }
        case .gppPublicString:
            guard let gppString = value, !gppString.isEmpty else {
                return
            }
            userDataManagerSharedInstance.setPublicGPPString(gppString)
        case .gppPublicSID:
            guard let gppSID = value, !gppSID.isEmpty else {
                return
            }
            userDataManagerSharedInstance.setPublicGPPSID(gppSID)
        default: return
        }
        
        setOutletsValues()
    }
    
    private func removeGPPData(type: Int){
        guard let gppType = GPPDataType(rawValue: type) else {
            return
        }
        removeGPPData(type: gppType)
    }
    
    private func removeGPPData(type: GPPDataType){
        switch type {
        case .gppInternalString: userDataManagerSharedInstance.removeInternalGPPString()
        case .gppInternalSID: userDataManagerSharedInstance.removeInternalGPPSID()
        case .gppInternalData: userDataManagerSharedInstance.removeGPPInternalData()
        case .gppPublicString: userDataManagerSharedInstance.removePublicGPPString()
        case .gppPublicSID: userDataManagerSharedInstance.removePublicGPPSID()
        case .gppData: userDataManagerSharedInstance.removeGPPData()
        }
        setOutletsValues()
    }
    
    // MARK: - Actions
    
    @IBAction private func showOneTrustConsentDialog(_ sender: Any) {
// FIXME: Replace OneTrust with UserCentrics
        /*
        if OTPublishersHeadlessSDK.shared.shouldShowBanner() {
            OTPublishersHeadlessSDK.shared.setupUI(self)
            OTPublishersHeadlessSDK.shared.showBannerUI()
        }
        else {
            OTPublishersHeadlessSDK.shared.setupUI(self)
            OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
        }
         */
    }
    
    
    @IBAction private func setGPPValue(_ sender: UIButton) {
        setGPPData(type: sender.tag)
    }
    
    
    @IBAction private func removeGPPValues(_ sender: UIButton) {
        removeGPPData(type: sender.tag)
    }
    
    // MARK: - Utils
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
    
    private func showWaitingSDKAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.waitingSDKInitAlert = UIAlertController(title: "Initializing oneTrust SDK", message: "Please wait (up to one minute) or come back later", preferredStyle: .alert)
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            
            let goBackAction = UIAlertAction(title: "Back", style: .default ) { _ in
                self.waitingSDKInitAlert.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
            self.waitingSDKInitAlert.addAction(goBackAction)
            self.waitingSDKInitAlert.view.addSubview(activityIndicator)
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.waitingSDKInitAlert.view.centerXAnchor, constant: 0).isActive = true
            activityIndicator.bottomAnchor.constraint(equalTo: self.waitingSDKInitAlert.view.bottomAnchor, constant: -45).isActive = true
            
            self.present(self.waitingSDKInitAlert, animated: true)
        }
    }
    
    private func showRetryInitSDKAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "OneTrust init SDK error:", message: "you can try later again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            let retryAction = UIAlertAction(title: "Retry", style: .cancel) { _ in
                
                HyBidGPPSDKInitializer.retryInitOneTrustSDK()
            }
            
            alert.addAction(okAction)
            alert.addAction(retryAction)
            
            self?.present(alert, animated: true)
        }
    }
    
    private func dismissWaitingSDKAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.waitingSDKInitAlert.dismiss(animated: true)
        }
    }
    
    private func hiddeGPPLabels(hidde: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.publicGPPStringLabel.isHidden = hidde
            self.publicGPPSIDLabel.isHidden = hidde
            self.internalGPPStringLabel.isHidden = hidde
            self.internalGPPSIDLabel.isHidden = hidde
            
            if !hidde {
                self.setOutletsValues()
            }
        }
    }
}

// MARK: - Extensions

extension HyBidGPPSettingsViewController: HyBidUserDataManagerDelegate {
    func gppValuesDidChange() {
        setOutletsValues()
    }
}

extension HyBidGPPSettingsViewController: HyBidGPPSDKInitializerDelegate {
    func sdkDidInitialized() {
        configureView()
    }
    
    func sdkDidFail(error: Error) {
        showRetryInitSDKAlert()
    }
}

// FIXME: Replace OneTrust with UserCentrics
//extension HyBidGPPSettingsViewController: OTEventListener {
//    func onHideBanner() {}
//    func onShowBanner() {}
//    func onBannerClickedRejectAll() {
//        removeGPPData(type: .gppData)
//    }
//    func onBannerClickedAcceptAll() {
//        setGPPData(type: .gppPublicString, value: gppStringDummyValue)
//        setGPPData(type: .gppPublicSID, value: gppSIDDummyValue)
//    }
//    func onShowPreferenceCenter() {}
//    func onHidePreferenceCenter() {}
//    func onPreferenceCenterRejectAll() {
//        removeGPPData(type: .gppData)
//    }
//    func onPreferenceCenterAcceptAll() {
//        setGPPData(type: .gppPublicString, value: gppStringDummyValue)
//        setGPPData(type: .gppPublicSID, value: gppSIDDummyValue)
//    }
//    func onPreferenceCenterConfirmChoices() {}
//    func onPreferenceCenterPurposeLegitimateInterestChanged(purposeId: String, legitInterest: Int8) {}
//    func onPreferenceCenterPurposeConsentChanged(purposeId: String, consentStatus: Int8) {}
//    func onShowVendorList() {}
//    func onHideVendorList() {}
//    func onVendorListVendorConsentChanged(vendorId: String, consentStatus: Int8) {}
//    func onVendorListVendorLegitimateInterestChanged(vendorId: String, legitInterest: Int8) {}
//    func onVendorConfirmChoices() {}
//    func allSDKViewsDismissed(interactionType: ConsentInteractionType) {}
//}
