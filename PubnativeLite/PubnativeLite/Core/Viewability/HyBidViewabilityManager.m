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
#import "OMIDImports.h"
#import "HyBidLogger.h"
#import "HyBidConstants.h"
#import "HyBid.h"

static NSString *const HyBidViewabilityPartnerName = @"Pubnativenet";
static NSString *const HyBidOMIDSDKJSFilename = @"omsdk";

@interface HyBidViewabilityManager()

@property (nonatomic, readwrite, strong) NSString* omidJSString;

@end

@implementation HyBidViewabilityManager

+ (instancetype)sharedInstance {
    static HyBidViewabilityManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewabilityMeasurementEnabled = YES;
        NSError *error;
        
        if (!OMIDPubnativenetSDK.sharedInstance.isActive) {
            [[OMIDPubnativenetSDK sharedInstance] activate];
            self.partner = [[OMIDPubnativenetPartner alloc] initWithName:HyBidViewabilityPartnerName versionString:HYBID_SDK_VERSION];
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Viewability Manager couldn't initialized properly with error: %@", error.debugDescription]];
        }
        
        if(!self.omidJSString){
            [self fetchOMIDJS];
        }
    }
    return self;
}

- (void)fetchOMIDJS {
    if(!self.isViewabilityMeasurementActivated)
        return;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *omSdkJSPath = [bundle pathForResource:HyBidOMIDSDKJSFilename ofType:@"js"];
    if (!omSdkJSPath) {
        return;
    }
    NSData *omSdkJsData = [NSData dataWithContentsOfFile:omSdkJSPath];
    self.omidJSString = [[NSString alloc] initWithData:omSdkJsData encoding:NSUTF8StringEncoding];
}

- (NSString *)getOMIDJS {
    if(!self.isViewabilityMeasurementActivated)
        return nil;
    
    NSString *scriptContent  = nil;
    @synchronized (self) {
        scriptContent  = self.omidJSString;
        if (!scriptContent) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Script Content is nil."];
            scriptContent=  @"";
        }
    }
    return scriptContent;
}


- (OMIDPubnativenetAdEvents *)getAdEvents:(OMIDPubnativenetAdSession*)omidAdSession {
    if (omidAdSession != self.omidAdSession) {
        NSError *adEventsError;
        self.omidAdSession = omidAdSession;
        self.adEvents = [[OMIDPubnativenetAdEvents alloc] initWithAdSession:self.omidAdSession error:&adEventsError];
    }
    return self.adEvents;
}

- (OMIDPubnativenetMediaEvents *)getMediaEvents:(OMIDPubnativenetAdSession*)omidAdSession {
    if (omidAdSession != self.omidMediaAdSession) {
        NSError *mediaEventsError;
        self.omidMediaAdSession = omidAdSession;
        self.omidMediaEvents = [[OMIDPubnativenetMediaEvents alloc] initWithAdSession:self.omidMediaAdSession error:&mediaEventsError];
    }
    return self.omidMediaEvents;
}

- (BOOL)isViewabilityMeasurementActivated {
    return OMIDPubnativenetSDK.sharedInstance.isActive && self.viewabilityMeasurementEnabled;
}

- (void)reportEvent:(NSString *)eventType {
    HyBidReportingEvent* impressionOccurredEvent = [[HyBidReportingEvent alloc]initWith:eventType adFormat:nil properties:nil];
    [[HyBid reportingManager]reportEventFor:impressionOccurredEvent];
}

@end
