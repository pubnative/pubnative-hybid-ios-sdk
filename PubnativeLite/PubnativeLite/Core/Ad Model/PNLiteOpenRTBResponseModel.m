// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteOpenRTBResponseModel.h"
#import "HyBidOpenRTBAdModel.h"

@implementation PNLiteOpenRTBResponseModel

- (void)dealloc {
    self.bids = nil;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
     self = [super initWithDictionary:dictionary];
     if (self) {
         if ([dictionary isKindOfClass:[NSDictionary class]]) {
             self.bids = [HyBidOpenRTBAdModel parseArrayValuesForBids:dictionary[@"seatbid"]];
         }
     }
     return self;
 }

@end
