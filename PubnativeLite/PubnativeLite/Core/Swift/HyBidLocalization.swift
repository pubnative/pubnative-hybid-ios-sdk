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

private let localizationTableName = "HyBidLocalizable"
private let defaultLanguage = "en"

enum HyBidLocalization: String {
    case customCTAButtonTitle = "get"
}

extension HyBidLocalization {
    func localized(defaultValue: String? = nil) -> String {
        return localizationFramework.localizedString(forKey: self.rawValue, value: (defaultValue != nil) ? defaultValue : self.rawValue, table: localizationTableName)
    }
    
    private var localizationFramework: Bundle {
        let localizationBundle = Bundle(for: HyBidCustomCTAView.self)
        guard let bundlePath = localizationBundle.path(forResource: preferredLanguage(of: localizationBundle), ofType: "lproj"),
              let bundle = Bundle(path: bundlePath) else { return .main }
        
        return bundle
    }
    
    private func preferredLanguage(of bundle: Bundle) -> String {
        let supportedLanguages = bundle.localizations
        let preferredLanguages = Locale.preferredLanguages
        let preferredLanguagesSupported: [String] = preferredLanguages.map { language in
            if supportedLanguages.contains(language) {
                return language
            }
            
            let languageCode = getLanguageCode(language)
            if supportedLanguages.contains(languageCode) {
                return languageCode
            }
            
            return ""
        }
        
        if let preferredLanguage = preferredLanguagesSupported.first, !preferredLanguage.isEmpty {
            return preferredLanguage
        }
        
        let currentIdentifier = Locale.current.identifier
        if supportedLanguages.contains(currentIdentifier) {
            return currentIdentifier
        }
        
        let languageCode = getLanguageCode(currentIdentifier)
        return supportedLanguages.contains(languageCode) ? languageCode : defaultLanguage
    }
    
    private func getLanguageCode(_ languageIdentifier: String) -> String {
        let languageIndex = languageIdentifier.firstIndex { character in
            character == "-" || character == "_"
        }
        
        if let languageIndex = languageIndex {
            let languagePosition = languageIdentifier.distance(from: languageIdentifier.startIndex, to: languageIndex)
            return String(languageIdentifier.prefix(languagePosition))
        }
        
        return languageIdentifier
    }
}
