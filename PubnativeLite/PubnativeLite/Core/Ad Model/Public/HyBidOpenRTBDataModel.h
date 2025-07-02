// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

 #import <Foundation/Foundation.h>
 #import "HyBidOpenRTBBaseModel.h"

 @interface HyBidOpenRTBDataModel : HyBidOpenRTBBaseModel

 @property (nonatomic, strong) NSString *type;
 @property (nonatomic, strong) NSDictionary *data;
 @property (nonatomic, readonly) NSString *text;
 @property (nonatomic, readonly) NSString *vast;
 @property (nonatomic, readonly) NSNumber *number;
 @property (nonatomic, readonly) NSString *url;
 @property (nonatomic, readonly) NSString *html;

 - (instancetype)initWithDictionary:(NSDictionary *)dictionary;
 - (instancetype)initWithDictionary:(NSDictionary *)dictionary preferedValue:(NSString *)key;
 - (instancetype)initWithHTMLAsset:(NSString *)assetName withValue:(NSString *)value;
 - (instancetype)initWithVASTAsset:(NSString *)assetName withValue:(NSString *)value;
 - (NSString *)stringFieldWithKey:(NSString *)key;
 - (NSNumber *)numberFieldWithKey:(NSString *)key;

 @end
