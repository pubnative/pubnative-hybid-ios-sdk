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

@objc
public class HyBidSessionManager: NSObject {
    @objc public static let sharedInstance = HyBidSessionManager()
    private let serialQueue = DispatchQueue(label: "com.verve.HyBid.serialQueueSessionManager")
    @objc public var impressionCounter: [String: Int] = [:]
    @objc public var sessionDuration: String = ""
   
    @objc private override init(){}
    
    @objc
    public func setStartSession(){
        let startTime = Date(timeIntervalSince1970: TimeInterval(Date().timeIntervalSince1970))
        UserDefaults.standard.set(startTime, forKey: Common.START_SESSION_TIMESTAMP)
    }
    
    @objc
    public func updateSession(zoneID: String) {
        var sessionDuration: TimeInterval
        let lastTimeStamp = NSDate(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970))
        UserDefaults.standard.set(lastTimeStamp, forKey: Common.LAST_SESSION_TIMESTAMP)
        self.incrementImpressionCounter(zoneID: zoneID)
        if let startTime = UserDefaults.standard.object(forKey: Common.START_SESSION_TIMESTAMP) as? Date{
            sessionDuration = lastTimeStamp.timeIntervalSince(startTime)
            self.sessionDuration = String(sessionDuration.milliseconds)
            UserDefaults.standard.set(sessionDuration.stringFromTimeInterval(), forKey: Common.SESSION_DURATION)
        }
    }
    
    @objc
    public func incrementImpressionCounter(zoneID: String){
        serialQueue.async {
            if self.impressionCounter.keys.contains(zoneID){
                if let num = self.impressionCounter[zoneID] {
                    self.impressionCounter[zoneID] = num + 1
                }
            } else {
                self.impressionCounter[zoneID] = 1
            }
        }
    }
    
    @objc
    public func sessionDuration(zoneID: String){
        if self.impressionCounter.isEmpty {
            self.updateSession(zoneID: zoneID)
        } else {
            if let lastTimeStamp = UserDefaults.standard.object(forKey: Common.LAST_SESSION_TIMESTAMP) as? Date{
                let now = NSDate(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970))
                let ttl = now.timeIntervalSince(lastTimeStamp as Date)
                
                if ttl.minutes >= 30 {
                    self.impressionCounter = [:]
                    self.setStartSession()
                    self.updateSession(zoneID: zoneID)
                } else {
                    self.updateSession(zoneID: zoneID)
                }
            }
        }
    }
    
    @objc
    public func setAgeOfAppSinceCreated(){
        if UserDefaults.standard.object(forKey: Common.AGE_OF_APP) == nil {
            let timeStamp = String(Date().millisecondsSince1970)
            UserDefaults.standard.set(timeStamp, forKey: Common.AGE_OF_APP)
        }
    }
    
    @objc
    public func getAgeOfApp() -> String {
        let installTimeString = UserDefaults.standard.string(forKey: Common.AGE_OF_APP)
        if let installTime = installTimeString {
            if (installTime != "") {
                let time = Int64(installTime) ?? 0
                let installValue = Date(milliseconds: time)
                let timestamp = Date()
                
                return String(Calendar.current.numberOfDaysBetween(installValue, and: timestamp))
            } else {
                return "0"
            }
        } else {
            return "0"
        }
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        return numberOfDays.day!
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension TimeInterval{
   
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    var milliseconds: Int {
        return Int(self * 1000)
    }
    
    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d.%0.2d",hours,minutes,seconds,ms)

    }
}
