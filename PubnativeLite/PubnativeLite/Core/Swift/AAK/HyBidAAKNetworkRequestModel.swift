//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//


@objc
public class HyBidAAKNetworkRequestModel: NSObject {
    
    private let aakNetworkIDsKey = "AdNetworkIdentifiers"
    
    @objc public func getAAKNetworkIDsString() -> String? {
        guard let networkItems = Bundle.main.object(forInfoDictionaryKey: aakNetworkIDsKey) as? [String] else {
            HyBidLogger.errorLog(fromClass: NSStringFromClass(HyBidAAKNetworkRequestModel.self),
                                 fromMethod: #function,
                                 withMessage: "The key `\(aakNetworkIDsKey)` could not be found in `info.plist` file of the app. Please add the required item and try again.")
            return .none
        }
        
        let joinedNetworkItems = networkItems.joined(separator: ",")
        
        guard !joinedNetworkItems.isEmpty,
              !joinedNetworkItems.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            HyBidLogger.errorLog(fromClass: NSStringFromClass(HyBidAAKNetworkRequestModel.self),
                                 fromMethod: #function,
                                 withMessage: "The key `\(aakNetworkIDsKey)` has an invalid value (e.g., empty or contains only whitespace). Please add the required item with a valid value and try again.")
            return .none
        }
        
        return joinedNetworkItems
    }
}
