// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidLogger: NSObject {
    
    public static var logLevel: HyBidLogLevel = HyBidLogLevelInfo
    
    @objc(setLogLevel:)
    public static func setLogLevel(_ logLevel: HyBidLogLevel) {
        let levelNames = [
            "None",
            "Error",
            "Warning",
            "Info",
            "Debug",
        ]
        
        let levelName = levelNames[Int(logLevel.rawValue)]
        print("HyBid Logger: Log level set to ", levelName)
        HyBidLogger.logLevel = logLevel
    }
    
    @objc
    public static func errorLog(fromClass className: String, fromMethod: String, withMessage: String) {
        if (logLevel.rawValue >= Int(HyBidLogLevelError.rawValue)) {
            internalLog(fromClass: className, fromMethod: fromMethod, withMessage: withMessage, logLevel: HyBidLogLevelError)
        }
    }
    
    @objc
    public static func warningLog(fromClass className: String, fromMethod: String, withMessage: String) {
        if (logLevel.rawValue >= Int(HyBidLogLevelWarning.rawValue)) {
            internalLog(fromClass: className, fromMethod: fromMethod, withMessage: withMessage, logLevel: HyBidLogLevelWarning)
        }
    }
    
    @objc
    public static func infoLog(fromClass className: String, fromMethod: String, withMessage: String) {
        if (logLevel.rawValue >= Int(HyBidLogLevelInfo.rawValue)) {
            internalLog(fromClass: className, fromMethod: fromMethod, withMessage: withMessage, logLevel: HyBidLogLevelInfo)
        }
    }
    
    @objc
    public static func debugLog(fromClass className: String, fromMethod: String, withMessage: String) {
        if (logLevel.rawValue >= Int(HyBidLogLevelDebug.rawValue)) {
            internalLog(fromClass: className, fromMethod: fromMethod, withMessage: withMessage, logLevel: HyBidLogLevelDebug)
        }
    }
    
    static func internalLog(fromClass className: String, fromMethod: String, withMessage: String, logLevel: HyBidLogLevel) {
        
        var logLevelString = "Error"
        switch logLevel {
            case HyBidLogLevelError: logLevelString = "Error"
            case HyBidLogLevelInfo: logLevelString = "Info"
            case HyBidLogLevelWarning: logLevelString = "Warning"
            default: logLevelString = "Debug"
        }
        
        print("\n ----------------------- \n [LOG TYPE]: \(logLevelString)\n [CLASS]: \(className)\n [METHOD]: \(fromMethod) \n [withMessage]: \(withMessage)\n -----------------------");
    }
}
