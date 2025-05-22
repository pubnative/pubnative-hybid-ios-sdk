// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
