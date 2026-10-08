//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTEventProcessor.h"

@class HyBidAd;

typedef NS_ENUM(NSInteger, HyBidClickThroughType) {
    HyBidClickThroughTypeNone,
    HyBidClickThroughTypeVideo,
    HyBidClickThroughTypeCompanion,
};

@interface HyBidAutomaticClickTrackingUtil : NSObject

+ (BOOL)isAutoClickSuppressedForAd:(HyBidAd *)ad;

+ (BOOL)sendClickTrackingURLs:(NSArray<NSString *> *)urls
                withProcessor:(HyBidVASTEventProcessor *)eventProcessor
                  alreadySent:(BOOL)alreadySent;

+ (BOOL)trackClickEventWithProcessor:(HyBidVASTEventProcessor *)eventProcessor
                      alreadyTracked:(BOOL)alreadyTracked;

+ (void)reportClickThroughURL:(NSString *)url type:(HyBidClickThroughType)type opened:(BOOL)opened;

@end
