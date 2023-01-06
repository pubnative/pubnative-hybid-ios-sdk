//
//  Copyright © 2018 PubNative. All rights reserved.
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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithHTMLAsset:(NSString *)assetName withValue:(NSString *)value;
- (instancetype)initWithVASTAsset:(NSString *)assetName withValue:(NSString *)value;
- (NSString *)stringFieldWithKey:(NSString *)key;
- (NSNumber *)numberFieldWithKey:(NSString *)key;
- (BOOL)hasFieldForKey:(NSString *)key;
- (NSDictionary *)dictionaryFieldWithKey:(NSString *)key;

@end
