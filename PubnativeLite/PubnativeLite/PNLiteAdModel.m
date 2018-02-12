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

#import "PNLiteAdModel.h"

@implementation PNLiteAdModel

- (void)dealloc
{
    self.link = nil;
    self.assets = nil;
    self.meta = nil;
    self.beacons = nil;
    self.assetgroupid = nil;
}

#pragma mark PNLiteBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.link = dictionary[@"link"];
        self.assetgroupid = dictionary[@"assetgroupid"];
        self.assets = [PNLiteDataModel parseArrayValues:dictionary[@"assets"]];
        self.meta = [PNLiteDataModel parseArrayValues:dictionary[@"meta"]];
        self.beacons = [PNLiteDataModel parseArrayValues:dictionary[@"beacons"]];;
    }
    return self;
}

#pragma mark PNLiteAdModel

- (PNLiteDataModel *)assetWithType:(NSString *)type
{
    PNLiteDataModel *result = nil;
    result = [self dataWithType:type fromList:self.assets];
    return result;
}

- (PNLiteDataModel *)metaWithType:(NSString *)type
{
    PNLiteDataModel *result = nil;
    result = [self dataWithType:type fromList:self.meta];
    return result;
}

- (NSArray *)beaconsWithType:(NSString *)type;
{
    NSArray *result = nil;
    result = [self allWithType:type fromList:self.beacons];
    return result;
}

- (PNLiteDataModel *)dataWithType:(NSString *)type
                         fromList:(NSArray *)list
{
    PNLiteDataModel *result = nil;
    if (list != nil) {
        for (PNLiteDataModel *data in list) {
            if ([type isEqualToString:data.type]) {
                result = data;
                break;
            }
        }
    }
    return result;
}

- (NSArray*)allWithType:(NSString *)type
               fromList:(NSArray *)list
{
    NSMutableArray *result = nil;
    if (list != nil) {
        for (PNLiteDataModel *data in list) {
            if ([type isEqualToString:data.type]) {
                if (result == nil) {
                    result = [[NSMutableArray alloc] init];
                }
                [result addObject:data];
            }
        }
    }
    return result;
}

@end
