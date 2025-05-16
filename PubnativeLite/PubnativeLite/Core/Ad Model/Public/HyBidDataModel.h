// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidBaseModel.h"

@interface HyBidDataModel : HyBidBaseModel

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *vast;
@property (nonatomic, readonly) NSNumber *number;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *js;
@property (nonatomic, readonly) NSString *html;
@property (nonatomic, readonly) NSNumber *eCPM;
@property (nonatomic, readonly) NSNumber *width;
@property (nonatomic, readonly) NSNumber *height;
@property (nonatomic, readonly) NSDictionary *jsonData;
@property (nonatomic, readonly) BOOL boolean;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithHTMLAsset:(NSString *)assetName withValue:(NSString *)value;
- (instancetype)initWithVASTAsset:(NSString *)assetName withValue:(NSString *)value;
- (NSString *)stringFieldWithKey:(NSString *)key;
- (NSNumber *)numberFieldWithKey:(NSString *)key;
- (BOOL)hasFieldForKey:(NSString *)key;
- (NSDictionary *)dictionaryFieldWithKey:(NSString *)key;

@end
