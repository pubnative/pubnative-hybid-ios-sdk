//
//  Copyright © 2019 PubNative. All rights reserved.
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

@class OMIDPubnativenetPartner;
@class OMIDPubnativenetAdEvents;
@class OMIDPubnativenetAdSession;
@class OMIDPubnativenetMediaEvents;

#import <Foundation/Foundation.h>

@interface HyBidViewabilityManager : NSObject

@property (nonatomic, assign) BOOL viewabilityMeasurementEnabled;
@property (nonatomic, assign) BOOL isViewabilityMeasurementActivated;
@property (nonatomic, strong) OMIDPubnativenetPartner *partner;
@property (nonatomic, strong) OMIDPubnativenetAdSession *omidAdSession;
@property (nonatomic, strong) OMIDPubnativenetAdSession *omidMediaAdSession;
@property (nonatomic, strong) OMIDPubnativenetAdEvents *adEvents;
@property (nonatomic, strong) OMIDPubnativenetMediaEvents *omidMediaEvents;

+ (instancetype)sharedInstance;
- (NSString *)getOMIDJS;
- (OMIDPubnativenetAdEvents *)getAdEvents:(OMIDPubnativenetAdSession*)omidAdSession;
- (OMIDPubnativenetMediaEvents *)getMediaEvents:(OMIDPubnativenetAdSession*)omidAdSession;
- (void) reportEvent: (NSString*)eventType;

@end
