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
    @objc public var counterPerZone: [String: Int] = [:]
   
    @objc private override init(){}
    
    @objc
    public func setStartSession(){
        let startTime = NSDate(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970))
        UserDefaults.standard.set(startTime, forKey: Common.START_SESSION_TIMESTAMP)
    }
    
    @objc
    public func updateSession()  {
        let lastTimeStamp = NSDate(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970))
        UserDefaults.standard.set(lastTimeStamp, forKey: Common.LAST_SESSION_TIMESTAMP)
    }
    
    @objc
    public func incrementImpressionCounter(zoneID: String){
        if counterPerZone.keys.contains(zoneID){
            if let num = counterPerZone[zoneID] {
                counterPerZone[zoneID] = num + 1
            }
        } else {
            counterPerZone[zoneID] = 1
        }
    }
    
    @objc
    public func sessionDuration(zoneID: String){
        let sessionDuration: TimeInterval
        let lastTimeStamp = NSDate(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970))
        UserDefaults.standard.set(lastTimeStamp, forKey: Common.LAST_SESSION_TIMESTAMP)
        
        if let date = UserDefaults.standard.object(forKey: Common.START_SESSION_TIMESTAMP) as? Date{
            sessionDuration = lastTimeStamp.timeIntervalSince(date)
           
            if sessionDuration.minutes > 30 {
                setStartSession()
                self.counterPerZone = [:]
                incrementImpressionCounter(zoneID: zoneID)
                updateSession()
            } else {
                incrementImpressionCounter(zoneID: zoneID)
            }
        }
    }
    
    @objc
    public func setAgeOfAppSinceCreated(){
        if (UserDefaults.standard.object(forKey: Common.AGE_OF_APP) == nil){
            let timeStamp = NSDate(timeIntervalSince1970: TimeInterval(NSDate().timeIntervalSince1970))
            UserDefaults.standard.set(timeStamp, forKey: Common.AGE_OF_APP)
        }
    }
}


extension TimeInterval{
   
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
}
