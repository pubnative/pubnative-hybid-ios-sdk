// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTAdTrackingEventType.h"
#import "HyBidVASTTracking.h"
#import "HyBidVASTImpression.h"

typedef NS_ENUM(NSInteger, HyBidVASTUrlType) {
    HyBidVASTImpressionURL,
    HyBidVASTClickTrackingURL,
    HyBidVASTIconClickTrackingURL,
    HyBidVASTParserErrorURL,
    HyBidVASTErrorURL,
};

@protocol HyBidVASTEventProcessorDelegate <NSObject>

- (void)eventProcessorDidTrackEventType:(HyBidVASTAdTrackingEventType)event;

@end

@interface HyBidVASTEventProcessor : NSObject

- (id)initWithEventsDictionary:(NSDictionary<NSString *, NSMutableArray<NSString *> *> *)eventDictionary progressEventsDictionary:(NSDictionary<NSString *, NSString *> *)progressEventDictionary delegate:(id<HyBidVASTEventProcessorDelegate>)delegate;


- (id)initWithEvents:(NSArray<HyBidVASTTracking *> *)events delegate:(id<HyBidVASTEventProcessorDelegate>)delegate;

// sends the given VASTEvent
- (void)trackEventWithType:(HyBidVASTAdTrackingEventType)type;
- (void)trackProgressEvent:(NSString*)offset;
- (void)trackImpression:(HyBidVASTImpression*)impression;
- (void)trackImpressionWith:(NSString*)impressionURL;

- (void)sendVASTBeaconUrl:(NSString *)url withTrackingType:(NSString *)trackingType beaconName:(NSString *)beaconName;
// sends the set of http requests to supplied URLs, used for Impressions, ClickTracking, and Errors.
- (void)sendVASTUrls:(NSArray *)urls withType:(HyBidVASTUrlType)type;

- (void)setCustomEvents:(NSArray<HyBidVASTTracking *> *)events;

@end
