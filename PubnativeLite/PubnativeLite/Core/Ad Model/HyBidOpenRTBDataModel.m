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

 #import "HyBidOpenRTBDataModel.h"
 #import "PNLiteMeta.h"
 #import "PNLiteData.h"

 @implementation HyBidOpenRTBDataModel

 - (void)dealloc {
     self.data = nil;
     self.type = nil;
 }

 #pragma mark HyBidBaseModel

 - (instancetype)initWithDictionary:(NSDictionary *)dictionary {
     self = [super initWithDictionary:dictionary];
     if (self) {
         if (dictionary[@"data"] != nil) {
             NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
             self.type = dictionary[@"data"][@"label"];

             id value = dictionary[@"data"][@"value"];
             [newDict setObject:value forKey:([self.type isEqual: @"rating"] ? @"number" : @"text")];
             [newDict removeObjectForKey:@"value"];

             self.data = newDict;
         } else if (dictionary[@"img"] != nil) {
             NSDictionary *typeDict = @{@1: @"icon", @3: @"banner"};
             self.type = typeDict[dictionary[@"img"][@"type"]];
             self.data = dictionary[@"img"];
         } else if (dictionary[@"title"] != nil) {
             self.type = @"title";
             self.data = dictionary[@"title"];
         } else if (dictionary[@"skadn"] != nil) {
             self.type = [PNLiteMeta skadnetwork];
             self.data = dictionary[@"skadn"];
         }
     }
     return self;
 }

 - (instancetype)initWithHTMLAsset:(NSString *)assetName withValue:(NSString *)value {
     self = [super initWithDictionary:[NSDictionary dictionary]];
     if (self) {
         self.type = assetName;
         self.data = [NSDictionary dictionaryWithObjectsAndKeys:value, @"html", nil];
     }
     return self;
 }

 - (instancetype)initWithVASTAsset:(NSString *)assetName withValue:(NSString *)value {
     self = [super initWithDictionary:[NSDictionary dictionary]];
     if (self) {
         self.type = assetName;
         self.data = [NSDictionary dictionaryWithObjectsAndKeys:value, @"vast2", nil];
     }
     return self;
 }

 #pragma mark HyBidOpenRTBDataModel

 - (NSString *)text {
     return [self stringFieldWithKey:PNLiteData.text];
 }

 - (NSString *)vast {
     return [self stringFieldWithKey:PNLiteData.vast];
 }

 - (NSNumber *)number {
     return [self numberFieldWithKey:PNLiteData.number];
 }

 - (NSString *)url {
     return [self stringFieldWithKey:PNLiteData.url];
 }

 - (NSString *)html {
     return [self stringFieldWithKey:PNLiteData.html];
 }

 - (NSString *)stringFieldWithKey:(NSString *)key {
     return (NSString *) [self dataWithKey:key];
 }

 - (NSNumber *)numberFieldWithKey:(NSString *)key {
     return (NSNumber *) [self dataWithKey:key];
 }

 - (NSObject *)dataWithKey:(NSString *)key {
     NSObject *result = nil;
     if (self.data != nil && [self.data objectForKey:key]) {
         result = [self.data objectForKey:key];
     }
     return result;
 }

 @end
