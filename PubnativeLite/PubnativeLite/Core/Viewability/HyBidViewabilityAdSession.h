// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HyBidViewabilityManager.h"

@interface HyBidViewabilityAdSession : NSObject

+ (instancetype)sharedInstance;
- (void)startOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession;
- (void)stopOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession;
- (void)fireOMIDImpressionOccuredEvent:(OMIDPubnativenetAdSession*)omidAdSession;
- (void)fireOMIDAdLoadEvent:(OMIDPubnativenetAdSession*)omidAdSession;
- (void)addFriendlyObstruction:(UIView *)view
               toOMIDAdSession:(OMIDPubnativenetAdSession*)omidAdSession
                    withReason:(NSString *)reasonForFriendlyObstruction
                isInterstitial:(BOOL)isInterstitial;
@end
