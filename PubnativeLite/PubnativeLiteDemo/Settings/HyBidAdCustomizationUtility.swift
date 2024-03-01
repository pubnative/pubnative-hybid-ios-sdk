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

import Foundation

let samplingEndpoint = "http://creative-sampler.herokuapp.com/customisation/config"

@objc
public class HyBidAdCustomizationUtility: NSObject {

    @objc
    static public func checkSavedHyBidAdSettings() -> ([[String: Any]]) {
        guard let jsonString = UserDefaults.standard.string(forKey: "AdSettings"),
              let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
              let configs = jsonObject["configs"] as? [[String: Any]] else {
            return []
        }
        return configs
    }
    
    @objc
    static public func postConfigToSamplingEndoing(withAdFormat adFormat: String, width: Int = 0, height: Int = 0, isFullscreen: Bool, isRewarded: Bool, admType: String, adContent: String, configs: [[String: Any]], completion: @escaping (Bool, String?) -> Void) {
        // Prepare the POST parameters
        var postParams: [String: Any] = [
            "format": adFormat,
            "os": "ios",
            "fullscreen": isFullscreen,
            "rewarded": isRewarded,
            "adm_type": admType,
            "adm": adContent,
            "configs": configs
        ]

        if let customEndcardInputValue = getCustomInputValue(from: configs, key: .customEndcardInputValue) {
            postParams[HyBidAdCustomizationKeys.customEndcardInputValue.rawValue] = customEndcardInputValue
        }
        
        if let customCTAInputValue = getCustomInputValue(from: configs, key: .customCTAInputValue) {
            postParams[HyBidAdCustomizationKeys.customCTAInputValue.rawValue] = customCTAInputValue
        }
        
        if let skAdNetworkModel = getCustomInputValue(from: configs, key: .skAdNetworkModelInputValue) {
            postParams[HyBidAdCustomizationKeys.skAdNetworkModelInputValue.rawValue] = skAdNetworkModel
        }
        
        if width != 0 && height != 0 {
            postParams["width"] = width
            postParams["height"] = height
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: postParams, options: []) else {
            completion(false, "Failed to serialize data to JSON")
            return
        }

        let url = URL(string: samplingEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
 
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let status = json["status"] as? String, let responseString = String(data: data, encoding: .utf8)  else {
                completion(false, "Invalid server response")
                return
            }

            if status == "error" {
                let errorMessage = json["error_message"] as? String ?? "Error"
                completion(false, errorMessage)
                return
            }
            completion(true, responseString)
        }
        task.resume()
    }

    static private func getCustomInputValue(from configs:[[String: Any]], key: HyBidAdCustomizationKeys) -> Any? {
        let filteredArray = configs.filter { config in
            guard let name = config[HyBidAdCustomizationKeys.name.rawValue] as? String,
                  name == key.rawValue else { return false }
            return true
        }
        
        guard let customInput = filteredArray.first,
              let customInputValue = customInput[HyBidAdCustomizationKeys.value.rawValue] else { return nil }
        
        switch key {
        case .customCTAInputValue, .customEndcardInputValue:
            guard let customInputValueString = customInputValue as? String else { return nil }
            return customInputValueString
        case .skAdNetworkModelInputValue:
            guard let skAdNetworkModelData = try? JSONSerialization.data(withJSONObject: customInputValue, options: []) else { return nil }
            return String(data: skAdNetworkModelData, encoding: .utf8)
        default:
            return nil
        }
    }
}
