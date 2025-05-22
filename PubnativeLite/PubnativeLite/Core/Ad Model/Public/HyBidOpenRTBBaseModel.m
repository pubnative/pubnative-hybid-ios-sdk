// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

 #import "HyBidOpenRTBBaseModel.h"

 @implementation HyBidOpenRTBBaseModel

 - (void)dealloc {
     self.dictionary = nil;
 }

 - (instancetype)initWithDictionary:(NSDictionary *)dictionary {
     self = [super init];
     if (self) {
         if ([dictionary isKindOfClass:[NSDictionary class]]) {
             self.dictionary = dictionary;
         }
     }
     return self;
 }

 + (NSArray *)parseArrayValuesForBids:(NSArray *)array {
     NSMutableArray *result;
     if(array && [array isKindOfClass: [NSArray class]]) {
         result = [NSMutableArray array];
         for (NSDictionary *valueDictionary in array) {
             for (NSDictionary *bidsDictionary in valueDictionary[@"bid"]) {
                 NSObject *value = [[self alloc] initWithDictionary:bidsDictionary];
                 [result addObject:value];
             }
         }
     }
     return result;
 }
 + (NSArray *)parseArrayValuesForAssets:(NSArray *)array {
     NSMutableArray *result;
     if(array && [array isKindOfClass: [NSArray class]]) {
         result = [NSMutableArray array];
         for (NSDictionary *valueDictionary in array) {
             NSObject *value = [[self alloc] initWithDictionary:valueDictionary];
             [result addObject:value];
         }
     }
     return result;
 }
 + (NSArray *)parseDictionaryValuesForExtensions:(NSDictionary *)dictionary {
     NSMutableArray *result;
     if(dictionary && [dictionary isKindOfClass: [NSDictionary class]]) {
         result = [NSMutableArray array];
         NSObject *value = [[self alloc] initWithDictionary:dictionary];
         [result addObject:value];
     }
     return result;
 }

 @end
