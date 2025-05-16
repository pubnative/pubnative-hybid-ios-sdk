// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

// MARK: - Extension Dictionary

extension Dictionary {
    mutating func update(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey: key)
        }
    }
}
