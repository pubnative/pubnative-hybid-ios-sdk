// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HyBidOMIDAdSessionWrapper.h"

@interface HyBidViewabilityAdSession : NSObject

+ (instancetype _Nonnull)sharedInstance;

- (void)startOMIDAdSession:(HyBidOMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)stopOMIDAdSession:(HyBidOMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)fireOMIDImpressionOccuredEvent:(HyBidOMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)fireOMIDAdLoadEvent:(HyBidOMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)addFriendlyObstruction:(UIView * _Nonnull)view
               toOMIDAdSession:(HyBidOMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper
                    withReason:(NSString * _Nonnull)reasonForFriendlyObstruction
                isInterstitial:(BOOL)isInterstitial;

@end


