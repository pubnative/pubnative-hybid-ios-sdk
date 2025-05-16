// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityManager.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

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
            self.partner = [[OMIDPubnativenetPartner alloc] initWithName:HyBidViewabilityPartnerName versionString:HyBidConstants.HYBID_SDK_VERSION];
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:[NSString stringWithFormat:@"Viewability Manager couldn't initialized properly with error: %@", error.debugDescription]];
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
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:@"Script Content is nil."];
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
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:eventType adFormat:nil properties:nil];
        [[HyBid reportingManager]reportEventFor:reportingEvent];
    }
}

@end
