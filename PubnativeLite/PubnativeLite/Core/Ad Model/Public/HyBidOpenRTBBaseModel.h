// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

 #import <Foundation/Foundation.h>

 @interface HyBidOpenRTBBaseModel : NSObject

 @property (nonatomic, strong) NSDictionary *dictionary;

 + (NSArray *)parseArrayValuesForBids:(NSArray *)array;
 + (NSArray *)parseArrayValuesForAssets:(NSArray *)array;
 + (NSArray *)parseDictionaryValuesForExtensions:(NSDictionary *)dictionary;
 - (instancetype)initWithDictionary:(NSDictionary *)dictionary;


 @end
