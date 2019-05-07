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

#import "HyBidViewabilityManager.h"
#import <OMSDK_Pubnativenet/OMIDSDK.h>
#import <OMSDK_Pubnativenet/OMIDPartner.h>
#import "HyBidLogger.h"

NSString *const HyBidViewabilityPartnerName = @"Pubnativenet";

@interface HyBidViewabilityManager()

@property (nonatomic, assign) BOOL viewabilityMeasurementActivated;

@end

@implementation HyBidViewabilityManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewabilityMeasurementEnabled = YES;
        NSError *error;
        self.viewabilityMeasurementActivated = [[OMIDPubnativenetSDK sharedInstance] activateWithOMIDAPIVersion:OMIDSDKAPIVersionString
                                                                                                          error:&error];
        if (self.viewabilityMeasurementActivated) {
//            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            self.partner = [[OMIDPubnativenetPartner alloc] initWithName:HyBidViewabilityPartnerName versionString:@"1.2.1"];
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Viewability Manager couldn't initialized properly with error: %@", error.debugDescription]];
        }
    }
    return self;
}

+ (instancetype)sharedInstance {
    static HyBidViewabilityManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityManager alloc] init];
    });
    return sharedInstance;
}

- (BOOL)isViewabilityMeasurementActivated {
    return self.viewabilityMeasurementActivated && self.viewabilityMeasurementEnabled;
}

@end
