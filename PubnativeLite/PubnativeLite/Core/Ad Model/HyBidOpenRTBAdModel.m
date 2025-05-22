// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

 #import "HyBidOpenRTBAdModel.h"
 #import "HyBidOpenRTBDataModel.h"
 #import "PNLiteAsset.h"

 @implementation HyBidOpenRTBAdModel

 - (void)dealloc {
     self.link = nil;
     self.assets = nil;
     self.extensions = nil;
     self.beacons = nil;
     self.assetgroupid = nil;
     self.creativeid = nil;
 }

 #pragma mark HyBidBaseModel

 - (instancetype)initWithDictionary:(NSDictionary *)dictionary {
     self = [super initWithDictionary:dictionary];
     if (self) {
         if ([dictionary isKindOfClass:[NSDictionary class]]) {
             NSData *admData = [dictionary[@"adm"] dataUsingEncoding:NSUTF8StringEncoding];
             
             if(admData != nil){
                 NSError *error;
                 NSDictionary *adm = [NSJSONSerialization JSONObjectWithData:admData options:kNilOptions error:&error];
                 
                 self.link = adm[@"native"][@"link"][@"url"];
                 self.assets = [NSMutableArray arrayWithArray:[HyBidOpenRTBDataModel parseArrayValuesForAssets:adm[@"native"][@"assets"]]];
                 self.creativeid = dictionary[@"crid"];
                 NSError *extError;
                 if (dictionary[@"ext"] != nil){
                     NSData *extData = [NSJSONSerialization dataWithJSONObject:dictionary[@"ext"] options:NSJSONWritingPrettyPrinted error:&extError];
                     NSDictionary *ext = [NSJSONSerialization JSONObjectWithData:extData options:kNilOptions error:&extError];
                     self.extensions = [NSMutableArray arrayWithArray:[HyBidOpenRTBDataModel parseDictionaryValuesForExtensions:ext]];
                 }
             }
         }
     }
     return self;
 }

 #pragma mark HyBidOpenRTBDataModel

 - (HyBidOpenRTBDataModel *)assetWithType:(NSString *)type {
     HyBidOpenRTBDataModel *result = nil;
     result = [self dataWithType:type fromList:self.assets];
     return result;
 }

 - (HyBidOpenRTBDataModel *)extensionWithType:(NSString *)type {
     HyBidOpenRTBDataModel *result = nil;
     result = [self dataWithType:type fromList:self.extensions];
     return result;
 }

 - (NSArray *)beaconsWithType:(NSString *)type {
     NSArray *result = nil;
     result = [self allWithType:type fromList:self.beacons];
     return result;
 }

 - (HyBidOpenRTBDataModel *)dataWithType:(NSString *)type
                          fromList:(NSArray *)list {
     HyBidOpenRTBDataModel *result = nil;
     if ([type isEqual: PNLiteAsset.htmlBanner]) {
         result = [[HyBidOpenRTBDataModel alloc] initWithHTMLAsset:PNLiteAsset.htmlBanner withValue:self.dictionary[@"adm"]];
     } else {
         if (list != nil) {
             for (HyBidOpenRTBDataModel *data in list) {
                 if ([type isEqualToString:data.type]) {
                     result = data;
                     break;
                 }
             }
         }
     }
     return result;
 }

 - (NSArray *)allWithType:(NSString *)type
                 fromList:(NSArray *)list {
     NSMutableArray *result = nil;
     if (list != nil) {
         for (HyBidOpenRTBDataModel *data in list) {
             if ([type isEqualToString:data.type]) {
                 if (!result) {
                     result = [[NSMutableArray alloc] init];
                 }
                 [result addObject:data];
             }
         }
     }
     return result;
 }

 @end
