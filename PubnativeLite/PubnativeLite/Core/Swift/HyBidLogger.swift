//
//  Copyright © 2020 PubNative. All rights reserved.
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
