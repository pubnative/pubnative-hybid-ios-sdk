//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

typedef void(^CompletionBlock)(HyBidAd* ad, NSError* error);

@interface HyBidAdSourceAbstract : NSObject

@property (nonatomic) CompletionBlock completionBlock;

- (void)fetchAdWithZoneId:(NSString*)zoneId completionBlock: (CompletionBlock)completionBlock;

@end
