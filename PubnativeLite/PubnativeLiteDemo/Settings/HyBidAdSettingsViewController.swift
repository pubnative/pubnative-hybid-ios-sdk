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
import HyBid

struct AdSetting {
    let sectionTitle: String
    let settingTitle: String
    let cellType: CellType
    var isChecked: Bool
    var remoteConfigName: String
    var value: Any?
}

let ClickBehaviorStringTitle = "Click Behavior"
enum ClickBehaviorString: String {
    case Creative = "creative"
    case Action_button = "action_button"
}

let AudioStatusStringTitle = "Initial Audio State"
enum AudioStatusString: String {
    case On = "on"
    case Muted = "muted"
    case Default = "default"
}

let CustomEndcardBehaviorStringTitle = "Custom EndCard Display"
enum CustomEndcardBehaviorString: String {
    case Extension = "extension"
    case Fallback = "fallback"
}

enum CellType {
    case switchCell
    case textFieldCell
    case numberFieldCell
    case dictionaryFieldCell
    case segmentedControlCell
}

enum TextInputType {
    case textField(UITextField? = nil)
    case textView(UITextView? = nil)
}

private typealias HyBidAdSettingsDictionary = Dictionary<String,Any>

@objc public protocol HyBidAdSettingsSamplingEndpoint: AnyObject {
    func didReceiveResponse(response: String)
    func didEncounterError(errorMessage: String)
}

@objc public class HyBidAdSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var adSettings: [[AdSetting]] = []
    
    @objc public weak var delegate: HyBidAdSettingsSamplingEndpoint?
    var spinner: UIActivityIndicatorView?

    @objc public var adFormat = ""
    @objc public var isFullscreen = false
    @objc public var isRewarded = false
    @objc public var adType = ""
    @objc public var adContent = ""
    
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupAdSettings()
        tableView.dataSource = self
        tableView.delegate = self
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        self.navigationItem.title = "Ad Settings"
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.rightBarButtonItem?.accessibilityLabel = "SaveButton"

        createAndCenterSpinner(in: self.view)
        loadAdSettingsFromUserDefaults()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func createAndCenterSpinner(in view: UIView) {
        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .medium)
        } else {
            spinner = UIActivityIndicatorView()
        }
        
        guard let spinner = spinner else {return}
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupAdSettings() {
           adSettings = [
               [
                AdSetting(sectionTitle: "General", settingTitle: "Native Close Button Delay", cellType: .numberFieldCell, isChecked: false, remoteConfigName: "close_button_delay" , value: HyBidConstants.nativeCloseButtonOffset.offset),
                AdSetting(sectionTitle: "General", settingTitle: AudioStatusStringTitle, cellType: .segmentedControlCell, isChecked: false, remoteConfigName: "audiostate", value: stringifyAudioStatus(with: HyBidConstants.audioStatus)),
                AdSetting(sectionTitle: "General", settingTitle: "Creative Autostore kit", cellType: .switchCell, isChecked: false, remoteConfigName: "creative_autostorekit", value: HyBidConstants.creativeAutoStorekitEnabled),
                AdSetting(sectionTitle: "General", settingTitle: "MRAID Expand Enabled", cellType: .switchCell, isChecked: false, remoteConfigName: "mraid_expand", value: HyBidConstants.mraidExpand),
                AdSetting(sectionTitle: "General", settingTitle: "SKOverlay Enabled", cellType: .switchCell, isChecked: false, remoteConfigName: "SKOverlayenabled", value: false),
                AdSetting(sectionTitle: "General", settingTitle: ClickBehaviorStringTitle, cellType: .segmentedControlCell, isChecked: false, remoteConfigName: "fullscreen_clickability", value: boolActionBehavior(with: HyBidConstants.interstitialActionBehaviour)),
                AdSetting(sectionTitle: "General", settingTitle: "ATOM Enabled", cellType: .switchCell, isChecked: false, remoteConfigName: "atom_enabled", value: HyBidConstants.atomEnabled)
               ],
               [
                AdSetting(sectionTitle: "Interstitial", settingTitle: "HTML/MRAID Skip Offset", cellType: .numberFieldCell, isChecked: false, remoteConfigName: "html_skip_offset", value: HyBidConstants.interstitialHtmlSkipOffset.offset),
                AdSetting(sectionTitle: "Interstitial", settingTitle: "Video Skip Offset", cellType: .numberFieldCell, isChecked: false, remoteConfigName: "video_skip_offset", value: HyBidConstants.videoSkipOffset.offset),
                AdSetting(sectionTitle: "Interstitial", settingTitle: "Close After Finish", cellType: .switchCell, isChecked: false, remoteConfigName: "close_inter_after_finished", value: HyBidConstants.interstitialCloseOnFinish)
               ],
               
               [
                AdSetting(sectionTitle: "Rewarded", settingTitle: "HTML/MRAID Skip Offset", cellType: .numberFieldCell, isChecked: false, remoteConfigName: "rewarded_html_skip_offset", value: HyBidConstants.rewardedHtmlSkipOffset.offset),
                AdSetting(sectionTitle: "Rewarded", settingTitle: "Video Skip Offset", cellType: .numberFieldCell, isChecked: false, remoteConfigName: "rewarded_video_skip_offset", value: HyBidConstants.rewardedVideoSkipOffset.offset),
                AdSetting(sectionTitle: "Rewarded", settingTitle: "Close After Finish", cellType: .switchCell, isChecked: false, remoteConfigName: "close_reward_after_finished", value: HyBidConstants.rewardedCloseOnFinish)
               ],
               
               [
                AdSetting(sectionTitle: "Endcard", settingTitle: "Show EndCard", cellType: .switchCell, isChecked: false, remoteConfigName: "endcardenabled", value: HyBidConstants.showEndCard),
                AdSetting(sectionTitle: "Endcard", settingTitle: "EndCard Close Delay", cellType: .numberFieldCell, isChecked: false, remoteConfigName: "endcard_close_delay", value: HyBidConstants.endCardCloseOffset.offset),
                AdSetting(sectionTitle: "Endcard", settingTitle: "Custom EndCard", cellType: .switchCell, isChecked: false, remoteConfigName: "custom_endcard_enabled", value: HyBidConstants.showCustomEndCard),
                AdSetting(sectionTitle: "Endcard", settingTitle: CustomEndcardBehaviorStringTitle, cellType: .segmentedControlCell, isChecked: false, remoteConfigName: "custom_endcard_display", value: stringifyDisplayBehavior(with: HyBidConstants.customEndcardDisplay)),
                AdSetting(sectionTitle: "Endcard", settingTitle: "Custom EndCard Value", cellType: .textFieldCell, isChecked: true, remoteConfigName: HyBidAdCustomizationKeys.customEndcardInputValue.rawValue, value: HyBidConstants.customEndCardInputValue),
               ],
               [
                AdSetting(sectionTitle: "Custom CTA", settingTitle: "Custom CTA Value", cellType: .textFieldCell, isChecked: true, remoteConfigName: HyBidAdCustomizationKeys.customCTAInputValue.rawValue, value: HyBidConstants.customCTAInputValue)
               ],
               [
                AdSetting(sectionTitle: "SKAN", settingTitle: "SKAN value", cellType: .dictionaryFieldCell, isChecked: true, remoteConfigName: "skadnetwork_input_value", value: HyBidConstants.skAdNetworkModelInputValue),
                AdSetting(sectionTitle: "SKAN", settingTitle: "Itunes ID", cellType: .textFieldCell, isChecked: true, remoteConfigName: "itunesid_value", value: HyBidConstants.itunesIdValue)

               ]
           ]
       }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return adSettings.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adSettings[section].count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !adSettings[section].isEmpty {
            return adSettings[section][0].sectionTitle
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if !adSettings[section].isEmpty, adSettings[section].contains(where: {$0.cellType == .dictionaryFieldCell && $0.remoteConfigName == HyBidAdCustomizationKeys.skAdNetworkModelInputValue.rawValue}){
            
            guard let row = adSettings[section].firstIndex(where: {$0.cellType == .dictionaryFieldCell && $0.remoteConfigName == HyBidAdCustomizationKeys.skAdNetworkModelInputValue.rawValue }) else { return }
            let indexPath = IndexPath(row: row, section: section)
            
            let sectionHeaderView = tableView.headerView(forSection: section)
            let clearTextButtonframe = CGRect(x: view.frame.size.width - 100, y: 0, width: 100, height: view.frame.size.height)

            let clearTextButton = UIButton(type: .system)
            clearTextButton.frame = clearTextButtonframe
            clearTextButton.tag = section * 1000 + indexPath.row
            clearTextButton.accessibilityLabel = "Clean Button " + adSettings[section][row].remoteConfigName
            clearTextButton.accessibilityValue = "Clean Button " + adSettings[section][row].remoteConfigName
            clearTextButton.isAccessibilityElement = true
            //in order to make clearTextButton visible 
            view.isAccessibilityElement = false
            clearTextButton.setTitle("Clean", for: .normal)
            clearTextButton.addTarget(self, action: #selector(cleanTextView), for: .touchUpInside)
            
            view.addSubview(clearTextButton)
            
            clearTextButton.translatesAutoresizingMaskIntoConstraints = false
            let verticalConstraint = clearTextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            let trailingConstraint = clearTextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            let widthConstraint = clearTextButton.widthAnchor.constraint(equalToConstant: clearTextButtonframe.width)
            let heightConstraint = clearTextButton.heightAnchor.constraint(equalToConstant: clearTextButtonframe.height)
            view.addConstraints([verticalConstraint, trailingConstraint, widthConstraint, heightConstraint])
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let adSetting = adSettings[indexPath.section][indexPath.row]
        
        switch adSetting.cellType {
        case .switchCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyBidSwitchTableViewCell", for: indexPath) as! HyBidSwitchTableViewCell
            cell.selectionStyle = .none

            cell.titleLabel.text = adSetting.settingTitle
            
            cell.toggleSwitch.isChecked = adSetting.isChecked
            cell.toggleSwitch.accessibilityLabel = "Checkbox "+adSetting.settingTitle
            cell.toggleSwitch.accessibilityValue = "\(adSetting.isChecked)"

            cell.additionalSwitch.accessibilityLabel = "Switch "+adSetting.settingTitle
            cell.additionalSwitch.accessibilityValue = "\(adSetting.value as? Bool ?? false)"

            cell.additionalSwitch.isOn = adSetting.value as? Bool ?? false
            cell.additionalSwitch.isEnabled = adSetting.isChecked
            cell.additionalSwitch.tag = indexPath.section * 1000 + indexPath.row
            cell.toggleSwitch.tag = indexPath.section * 1000 + indexPath.row
            
            cell.additionalSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            cell.toggleSwitch.addTarget(self, action: #selector(toggleSwitchValueChanged(_:)), for: .valueChanged)
            return cell

        case .numberFieldCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyBidTextFieldTableViewCell", for: indexPath) as! HyBidTextFieldTableViewCell
            cell.selectionStyle = .none

            cell.titleLabel.text = adSetting.settingTitle

            cell.toggleSwitch.isChecked = adSetting.isChecked
            cell.toggleSwitch.accessibilityLabel = "Checkbox "+adSetting.settingTitle
            cell.toggleSwitch.accessibilityValue = "\(adSetting.isChecked)"

            cell.textField.accessibilityLabel = "Textfield "+adSetting.settingTitle
            cell.textField.isEnabled = adSetting.isChecked
            cell.textField.delegate = self
            setupDoneButtonOnKeyboard(with: .textField(cell.textField))
            cell.textField.keyboardType = .numberPad

            if let value = adSetting.value {
                if let stringValue = value as? String {
                    cell.textField.text = stringValue
                } else if let numberValue = value as? NSNumber {
                    cell.textField.text = numberValue.stringValue
                }
            }
            
            cell.toggleSwitch.tag = indexPath.section * 1000 + indexPath.row
            cell.textField.tag = indexPath.section * 1000 + indexPath.row

            cell.textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
            cell.toggleSwitch.addTarget(self, action: #selector(toggleSwitchValueChanged(_:)), for: .valueChanged)
            return cell

        case .textFieldCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyBidTextInputOnlyTableViewCell", for: indexPath) as! HyBidTextInputOnlyTableViewCell
            cell.selectionStyle = .none
            cell.textField.placeholder = adSetting.settingTitle
            cell.textField.accessibilityLabel = "Textfield "+adSetting.settingTitle
            cell.textField.isEnabled = adSetting.isChecked
            cell.textField.delegate = self
            setupDoneButtonOnKeyboard(with: .textField(cell.textField))
           
            cell.textField.text = adSetting.value as? String
            cell.textField.tag = indexPath.section * 1000 + indexPath.row
            cell.textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
            return cell
        case .dictionaryFieldCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyBidTextViewTableViewCell", for: indexPath) as! HyBidTextViewTableViewCell
            cell.textViewHeight = self.view.frame.size.height / 4
            cell.selectionStyle = .none
            cell.placeholder = adSetting.settingTitle
            cell.textView.accessibilityLabel = "TextView "+adSetting.settingTitle
            cell.textView.isEditable = adSetting.isChecked
            cell.textView.delegate = self
            setupDoneButtonOnKeyboard(with: .textView(cell.textView))
            
            if let data = (adSetting.value as? HyBidAdSettingsDictionary), !data.isEmpty {
                let sortedData = data.sorted(by: {$0.key > $1.key })
                cell.textView.text = sortedData.description
                cell.placeholder = String()
            }
            cell.textView.tag = indexPath.section * 1000 + indexPath.row
            return cell
        case .segmentedControlCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyBidSegmentedControlTableViewCell", for: indexPath) as! HyBidSegmentedControlTableViewCell
            cell.selectionStyle = .none

            cell.titleLabel.text = adSetting.settingTitle

            cell.toggleSwitch.isChecked = adSetting.isChecked
            cell.toggleSwitch.accessibilityLabel = "Checkbox "+adSetting.settingTitle
            cell.toggleSwitch.accessibilityValue = "\(adSetting.isChecked)"

            cell.segmentedControl.isEnabled = adSetting.isChecked

            if adSetting.settingTitle == ClickBehaviorStringTitle {
                
                let selectedIndex = adSetting.value as? Bool ?? false ? 0 : 1
                
                while cell.segmentedControl.numberOfSegments > 0 {
                    cell.segmentedControl.removeSegment(at: 0, animated: false)
                }
                
                cell.segmentedControl.insertSegment(withTitle: ClickBehaviorString.Creative.rawValue, at: 0, animated: false)
                cell.segmentedControl.insertSegment(withTitle: ClickBehaviorString.Action_button.rawValue, at: 1, animated: false)
                cell.segmentedControl.selectedSegmentIndex = selectedIndex
                
            }
      
            if adSetting.settingTitle == CustomEndcardBehaviorStringTitle {

                let selectedIndex = adSetting.value as? String == CustomEndcardBehaviorString.Extension.rawValue ? 0 : 1
                
                while cell.segmentedControl.numberOfSegments > 0 {
                    cell.segmentedControl.removeSegment(at: 0, animated: false)
                }
                cell.segmentedControl.insertSegment(withTitle: CustomEndcardBehaviorString.Extension.rawValue, at: 0, animated: false)
                cell.segmentedControl.insertSegment(withTitle: CustomEndcardBehaviorString.Fallback.rawValue, at: 1, animated: false)
                cell.segmentedControl.selectedSegmentIndex = selectedIndex

            }

            if adSetting.settingTitle == AudioStatusStringTitle {

                
                var selectedIndex = 2
                if adSetting.value as? String == AudioStatusString.Muted.rawValue {
                    selectedIndex = 0
                } else if adSetting.value as? String == AudioStatusString.On.rawValue {
                    selectedIndex = 1
                }

                while cell.segmentedControl.numberOfSegments > 0 {
                    cell.segmentedControl.removeSegment(at: 0, animated: false)
                }
                
                cell.segmentedControl.insertSegment(withTitle: AudioStatusString.Muted.rawValue, at: 0, animated: false)
                cell.segmentedControl.insertSegment(withTitle: AudioStatusString.On.rawValue, at: 1, animated: false)
                cell.segmentedControl.insertSegment(withTitle: AudioStatusString.Default.rawValue, at: 2, animated: false)
                
                cell.segmentedControl.selectedSegmentIndex = selectedIndex

            }
            
            cell.toggleSwitch.tag = indexPath.section * 1000 + indexPath.row
            cell.segmentedControl.tag = indexPath.section * 1000 + indexPath.row
            
            if let selectedIndex = adSetting.value as? Int {
                cell.segmentedControl.selectedSegmentIndex = selectedIndex
            }
            
            cell.segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
            cell.toggleSwitch.addTarget(self, action: #selector(toggleSwitchValueChanged(_:)), for: .valueChanged)
            return cell
        }
    }

    @objc func switchValueChanged(_ sender: UISwitch) {
        let row = sender.tag % 1000
        let section = sender.tag / 1000
        var adSetting = adSettings[section][row]
        adSetting.value = sender.isOn
        adSettings[section][row] = adSetting
    }

    @objc func toggleSwitchValueChanged(_ sender: UICheckbox) {
        let row = sender.tag % 1000
        let section = sender.tag / 1000
        var adSetting = adSettings[section][row]
        adSetting.isChecked = sender.isChecked
        adSettings[section][row] = adSetting
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
    }

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let row = sender.tag % 1000
        let section = sender.tag / 1000
        var adSetting = adSettings[section][row]
        
        if adSetting.settingTitle == ClickBehaviorStringTitle {
            adSetting.value = sender.selectedSegmentIndex == 0
        }
        
        if (adSetting.settingTitle == AudioStatusStringTitle) {
            switch sender.selectedSegmentIndex {
            case 0:
                adSetting.value = AudioStatusString.Muted.rawValue
            case 1:
                adSetting.value = AudioStatusString.On.rawValue
            case 2:
                adSetting.value = AudioStatusString.Default.rawValue
            default:
                break;
            }
        }

        if (adSetting.settingTitle == CustomEndcardBehaviorStringTitle) {
            switch sender.selectedSegmentIndex {
            case 0:
                adSetting.value = CustomEndcardBehaviorString.Extension.rawValue
            case 1:
                adSetting.value = CustomEndcardBehaviorString.Fallback.rawValue
            default:
                break;
            }
        }
        
        adSettings[section][row] = adSetting
        
    }

    @objc func textFieldValueChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        fieldValueChange(text: text, senderTag: sender.tag)
    }
    
    func fieldValueChange(text: String, senderTag: Int) {
        let row = senderTag % 1000
        let section = senderTag / 1000
        var adSetting = adSettings[section][row]
        
        switch adSetting.cellType {
        case .textFieldCell:
            adSetting.value = text
        case .numberFieldCell:
            adSetting.value = Int(text) ?? nil
        case .dictionaryFieldCell:
            if let data = text.data(using: .utf8) {
                do {
                    adSetting.value = try JSONSerialization.jsonObject(with: data, options: []) as? HyBidAdSettingsDictionary
                } catch {
                    adSetting.value = nil
                }
            }
        default:
            break;
        }

        adSettings[section][row] = adSetting
    }

}

extension HyBidAdSettingsViewController {
    
    @objc func saveButtonTapped() {

        var configs: [[String: Any]] = []

        for section in adSettings {
            for setting in section {
                if setting.isChecked, let value = setting.value {
                    let name = setting.remoteConfigName
                    var castedValue: Any?
                    
                    switch setting.cellType {
                    case .switchCell: if let boolValue = value as? Bool { castedValue = boolValue }
                    case .numberFieldCell: if let intValue = value as? Int { castedValue = intValue }
                    case .textFieldCell: if let stringValue = value as? String, !stringValue.trimmingCharacters(in: .whitespaces).isEmpty { castedValue = stringValue }
                    case .dictionaryFieldCell: if let dictValue = value as? HyBidAdSettingsDictionary, !dictValue.isEmpty {
                        castedValue = dictValue
                    }
                    case .segmentedControlCell:
                        if let boolValue = value as? Bool {
                            castedValue = boolValue
                        } else if let stringValue = value as? String,
                                    !stringValue.trimmingCharacters(in: .whitespaces).isEmpty {
                            castedValue = stringValue
                        }
                    }

                    if let castedValue = castedValue {
                        let config: [String: Any] = ["name": name, "value": castedValue]
                        configs.append(config)
                    }
                }
            }
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: ["configs": configs], options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            UserDefaults.standard.setValue(jsonString, forKey: "AdSettings")
            self.dismissKeyboard()
            self.showAlertConfigSamplingEndpointFinished(with: true)
        } else {
            self.showAlertConfigSamplingEndpointFinished(with: false)
        }

    }

    private func loadAdSettingsFromUserDefaults() {
        
        let configs = HyBidAdCustomizationUtility.checkSavedHyBidAdSettings()
        guard !configs.isEmpty else {
            return
        }
        
        configs.forEach { config in
            guard let name = config["name"] as? String, let value = config["value"] else { return }
            
            for (sectionIndex, section) in adSettings.enumerated() {
                if let settingIndex = section.firstIndex(where: { $0.remoteConfigName == name }) {
                    
                    switch adSettings[sectionIndex][settingIndex].cellType {
                    case .switchCell:
                        if let boolValue = value as? Bool {
                            adSettings[sectionIndex][settingIndex].value = boolValue
                        }
                    case .segmentedControlCell:
                        if let boolValue = value as? Bool {
                            adSettings[sectionIndex][settingIndex].value = boolValue
                        } else if let stringValue = value as? String {
                            adSettings[sectionIndex][settingIndex].value = stringValue
                        }
                    case .textFieldCell:
                        if let stringValue = value as? String {
                            adSettings[sectionIndex][settingIndex].value = stringValue
                        }
                    case .numberFieldCell:
                        if let intValue = value as? Int {
                            adSettings[sectionIndex][settingIndex].value = intValue
                        }
                    case .dictionaryFieldCell:
                        if let dictValue = value as? HyBidAdSettingsDictionary {
                            adSettings[sectionIndex][settingIndex].value = dictValue
                        }
                    }
                    adSettings[sectionIndex][settingIndex].isChecked = true
                }
            }
        }
    }
    
    func boolActionBehavior(with actionBehavior: HyBidInterstitialActionBehaviour) -> Bool {
        switch actionBehavior {
        case HB_CREATIVE :
            return true
        default:
            return false
        }
    }

    func stringifyDisplayBehavior(with displayBehavior: HyBidCustomEndcardDisplayBehaviour) -> String {
        switch displayBehavior {
        case HyBidCustomEndcardDisplayExtention :
            return CustomEndcardBehaviorString.Extension.rawValue
        default:
            return CustomEndcardBehaviorString.Fallback.rawValue
        }
    }
    
    func stringifyAudioStatus(with audioStatus: HyBidAudioStatus) -> String {
        switch audioStatus {
        case HyBidAudioStatusON :
            return AudioStatusString.On.rawValue
        case HyBidAudioStatusMuted :
            return AudioStatusString.Muted.rawValue
        case HyBidAudioStatusDefault :
            return AudioStatusString.Default.rawValue
        default:
            return AudioStatusString.Default.rawValue
        }
    }
}

extension HyBidAdSettingsViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            let endPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
        }
        self.activeTextField = textField
    }
}

extension HyBidAdSettingsViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        fieldValueChange(text: textView.text, senderTag: textView.tag)
        determinePlaceholderVisibility(textView: textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        determinePlaceholderVisibility(textView: textView)
    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
        determinePlaceholderVisibility(textView: textView)
        self.activeTextView = textView
    }
    
    private func determinePlaceholderVisibility(textView: UITextView) {
        let placeholderLabel = textView.subviews.compactMap { $0 as? UILabel }.first
        if (placeholderLabel != nil) {
            placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }
    
    @objc private func cleanTextView(sender: UIButton){
        let row = sender.tag % 1000
        let section = sender.tag / 1000
        let indexPath = IndexPath(row: row, section: section)
        
        let cell = tableView.cellForRow(at: indexPath)
        guard let dictionaryCell = cell as? HyBidTextViewTableViewCell else { return }
        
        dictionaryCell.textView.text = nil
        textViewDidChange(dictionaryCell.textView)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension HyBidAdSettingsViewController {
    
    func showAlertConfigSamplingEndpointFinished(with success: Bool) {
        
        var title = "Config saved"
        if !success {
            title = "An Error occured"
        }
        let message = ""
        let okButtonTitle = "OK"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: { _ in
            if (success) {
                self.dismiss(animated: true)
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupDoneButtonOnKeyboard(with sender: TextInputType) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        switch sender {
        case .textField(let textField):
            textField?.inputAccessoryView = toolbar
            self.activeTextField = textField
        case .textView(let textView):
            textView?.inputAccessoryView = toolbar
            self.activeTextView = textView
        }
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        
        tableView.contentInset = contentInsets
        self.tableView.layoutIfNeeded()
        
        var activeField: UIView? = nil
        if let activeTextField = self.activeTextField, activeTextField.isFirstResponder {
            activeField = activeTextField
        }
        
        if let activeTextView = self.activeTextView, activeTextView.isFirstResponder {
            activeField = activeTextView
        }
        
        guard let activeField else { return }
        
        let row = activeField.tag % 1000
        let section = activeField.tag / 1000
        let activeTextFieldIndexPath = IndexPath(row: row, section: section)
        tableView.scrollToRow(at: activeTextFieldIndexPath, at: .bottom, animated: true)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
}
