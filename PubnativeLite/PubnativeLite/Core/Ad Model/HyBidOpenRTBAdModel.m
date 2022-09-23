//
 //  Copyright © 2020 PubNative. All rights reserved.
 //
 //  Permission is hereby granted, free of charge, to any person obtaining a copy
 //  of this software and associated documentation files (the "Software"), to deal
 //  in the Software without restriction, including without limitation the rights
 //  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 //  copies of the Software, and to permit persons to whom the Software is
 //  furnished to do so, subject to the following conditions:
 //
 //  The above copyright notice and this permission notice shall be included in
 //  all copies or substantial portions of the Software.
 //
 //  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 //  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 //  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 //  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 //  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 //  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 //  THE SOFTWARE.
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
 }

 #pragma mark HyBidBaseModel

 - (instancetype)initWithDictionary:(NSDictionary *)dictionary {
     self = [super initWithDictionary:dictionary];
     if (self) {
         NSData *admData = [dictionary[@"adm"] dataUsingEncoding:NSUTF8StringEncoding];
         NSError *error;
         NSDictionary *adm = [NSJSONSerialization JSONObjectWithData:admData options:kNilOptions error:&error];

         self.link = adm[@"native"][@"link"][@"url"];
         self.assets = [NSMutableArray arrayWithArray:[HyBidOpenRTBDataModel parseArrayValuesForAssets:adm[@"native"][@"assets"]]];

         NSError *extError;
         NSData *extData = [NSJSONSerialization dataWithJSONObject:dictionary[@"ext"] options:NSJSONWritingPrettyPrinted error:&extError];
         NSDictionary *ext = [NSJSONSerialization JSONObjectWithData:extData options:kNilOptions error:&extError];
         self.extensions = [NSMutableArray arrayWithArray:[HyBidOpenRTBDataModel parseDictionaryValuesForExtensions:ext]];
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
