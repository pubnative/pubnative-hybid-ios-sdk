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
@property (nonatomic, strong) HyBidOMIDAdSessionWrapper *omidAdSessionWrapper;
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

- (id)getAdEvents:(HyBidOMIDAdSessionWrapper *)omidAdSessionWrapper {
    if (!omidAdSessionWrapper.adSession) return nil;

    @synchronized(self) {
        if (!self.omidAdSession || self.omidAdSession.adSession != omidAdSessionWrapper.adSession) {
            self.omidAdSession = omidAdSessionWrapper;
            
            NSError *adEventsError = nil;
            if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
                #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
                self.adEvents = [[OMIDPubnativenetAdEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession
                                                                              error:&adEventsError];
                #endif
            } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
                #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
                self.adEvents = [[OMIDSmaatoAdEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession error:&adEventsError];
                #endif
            }
            
            if (adEventsError) {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Failed to initialize ad events: %@", adEventsError.localizedDescription]];
            }
        }

        return self.adEvents;
    }
}

- (id)getMediaEvents:(HyBidOMIDAdSessionWrapper *)omidAdSessionWrapper {
    if (!omidAdSessionWrapper.adSession) return nil;

    NSError *mediaEventsError = nil;
    id mediaEvents = nil;
    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        mediaEvents = [[OMIDPubnativenetMediaEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession error:&mediaEventsError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        mediaEvents = [[OMIDSmaatoMediaEvents alloc] initWithAdSession:omidAdSessionWrapper.adSession error:&mediaEventsError];
        #endif
    }
    
    if (mediaEventsError) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Failed to initialize media events: %@", mediaEventsError.localizedDescription]];
    }

    return mediaEvents;
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
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent *reportingEvent = [[HyBidReportingEvent alloc] initWith:eventType adFormat:nil properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"reporting event %@", eventType]];
    }
}

@end
