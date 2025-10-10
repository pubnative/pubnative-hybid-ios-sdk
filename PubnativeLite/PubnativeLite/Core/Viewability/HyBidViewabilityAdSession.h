// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OMIDAdSessionWrapper.h"

@interface HyBidViewabilityAdSession : NSObject

+ (instancetype _Nonnull)sharedInstance;

- (void)startOMIDAdSession:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)stopOMIDAdSession:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)fireOMIDImpressionOccuredEvent:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)fireOMIDAdLoadEvent:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper;
- (void)addFriendlyObstruction:(UIView * _Nonnull)view
               toOMIDAdSession:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper
                    withReason:(NSString * _Nonnull)reasonForFriendlyObstruction
                isInterstitial:(BOOL)isInterstitial;

@end


