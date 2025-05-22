// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVGIAppUser.h"
#import "HyBidVGIPrivacy.h"

@interface HyBidVGIApp : NSObject

@property (nonatomic, strong) NSString *bundleID;
@property (nonatomic, strong) NSArray<HyBidVGIAppUser *> *users;
@property (nonatomic, strong) HyBidVGIPrivacy *privacy;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
