// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
    #import <OMSDK_Pubnativenet/OMIDImports.h>
#endif

#if __has_include(<OMSDK_Smaato/OMIDImports.h>)
    #import <OMSDK_Smaato/OMIDImports.h>
#endif

static NSString *const OMIDSDKJSFilename = @"omsdk";

@interface HyBidViewabilityManager ()
@property (nonatomic, strong) NSString *omidJSString;
@property (nonatomic, strong) OMIDAdSessionWrapper *omidAdSessionWrapper;
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
        [self activateOMSDK];
        [self fetchOMIDJS];
    }
    return self;
}

#pragma mark - OM SDK Activation

- (void)activateOMSDK {
    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        if (!OMIDPubnativenetSDK.sharedInstance.isActive) {
            [[OMIDPubnativenetSDK sharedInstance] activate];
        }
        self.partner = [[OMIDPubnativenetPartner alloc] initWithName:HyBidConstants.HYBID_OMSDK_IDENTIFIER versionString:HyBidConstants.HYBID_SDK_VERSION];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        if (!OMIDSmaatoSDK.sharedInstance.isActive) {
            [[OMIDSmaatoSDK sharedInstance] activate];
        }
        self.partner = [[OMIDSmaatoPartner alloc] initWithName:HyBidConstants.SMAATO_OMSDK_IDENTIFIER versionString:HyBidConstants.SMAATO_SDK_VERSION];
        #endif
    }
}

#pragma mark - Fetching OMID JS

- (void)fetchOMIDJS {
    if (![self isViewabilityMeasurementActivated]) return;

    NSString *omidFilename = OMIDSDKJSFilename;
    
    if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        omidFilename = @"omsdk_Smaato";
    }

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:omidFilename ofType:@"js"];
    
    if (!path) return;
    
    NSData *jsData = [NSData dataWithContentsOfFile:path];
    self.omidJSString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
}

- (NSString *)getOMIDJS {
    return self.omidJSString;
}

#pragma mark - OMID Event Handling

- (id)getAdEvents:(OMIDAdSessionWrapper *)omidAdSessionWrapper {
    if (!omidAdSessionWrapper.adSession) return nil;

    NSError *adEventsError;
    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        return [[OMIDPubnativenetAdEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession error:&adEventsError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        return [[OMIDSmaatoAdEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession error:&adEventsError];
        #endif
    }

    return nil;
}

- (id)getMediaEvents:(OMIDAdSessionWrapper *)omidAdSessionWrapper {
    if (!omidAdSessionWrapper.adSession) return nil;

    NSError *mediaEventsError;
    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        return [[OMIDPubnativenetMediaEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession error:&mediaEventsError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        return [[OMIDSmaatoMediaEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession error:&mediaEventsError];
        #endif
    }

    return nil;
}

#pragma mark - Activation Status

- (BOOL)isViewabilityMeasurementActivated {
    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        return OMIDPubnativenetSDK.sharedInstance.isActive && self.viewabilityMeasurementEnabled;
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        return OMIDSmaatoSDK.sharedInstance.isActive && self.viewabilityMeasurementEnabled;
        #endif
    }
    return NO;
}

#pragma mark - Reporting Events

- (void)reportEvent:(NSString *)eventType {
    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<HyBid/HyBid-Swift.h>)
        if ([HyBidSDKConfig sharedConfig].reporting) {
            HyBidReportingEvent *reportingEvent = [[HyBidReportingEvent alloc] initWith:eventType adFormat:nil properties:nil];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"HyBid reporting event %@", eventType]];
        }
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Smaato reporting event %@", eventType]];
    }
}

@end
