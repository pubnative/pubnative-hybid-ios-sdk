//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <CoreLocation/CoreLocation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "HyBidTargetingModel.h"

typedef enum {
    HyBidAudioStatusMuted,
    HyBidAudioStatusON,
    HyBidAudioStatusDefault
} HyBidAudioStatus;

@interface HyBidSettings : NSObject

// CONFIGURABLE PARAMETERS
@property (nonatomic, assign) BOOL test;
@property (nonatomic, assign) BOOL coppa;
@property (nonatomic, strong) HyBidTargetingModel *targeting;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSString *apiURL;
@property (nonatomic, strong) NSString *openRtbApiURL;
@property (nonatomic, strong) NSString *appID;
@property (nonatomic, assign) NSInteger skipOffset;
@property (nonatomic, assign) BOOL closeOnFinish;
@property (nonatomic, assign) HyBidAudioStatus audioStatus;

// COMMON PARAMETERS
@property (readonly) NSString *advertisingId;
@property (readonly) NSString *os;
@property (readonly) NSString *osVersion;
@property (readonly) NSString *deviceName;
@property (readonly) NSString *deviceWidth;
@property (readonly) NSString *deviceHeight;
@property (readonly) NSString *orientation;
@property (readonly) NSString *deviceSound;
@property (readonly) NSString *locale;
@property (readonly) NSString *sdkVersion;
@property (readonly) NSString *appBundleID;
@property (readonly) NSString *appVersion;
@property (readonly) BOOL locationTrackingEnabled;
@property (readonly) BOOL locationUpdatesEnabled;
@property (readonly) CLLocation *location;
@property (readonly) NSString *identifierForVendor;
@property (readonly) NSString *ip;

+ (HyBidSettings *)sharedInstance;

@end
