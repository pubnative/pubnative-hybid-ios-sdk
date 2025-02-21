//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidConfigModel.h"

@implementation HyBidConfigModel

- (void)dealloc {
    self.appLevel = nil;
}

#pragma mark HyBidBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.appLevel = [NSMutableArray arrayWithArray:[HyBidDataModel parseArrayValues:dictionary[@"app_level"]]];
    }
    return self;
}

#pragma mark HyBidConfigModel

- (HyBidDataModel *)appLevelWithType:(NSString *)type {
    HyBidDataModel *result = nil;
    result = [self dataWithType:type fromList:self.appLevel];
    return result;
}


- (HyBidDataModel *)dataWithType:(NSString *)type
                        fromList:(NSArray *)list {
    HyBidDataModel *result = nil;
    if (list != nil) {
        for (HyBidDataModel *data in list) {
            if ([type isEqualToString:data.type]) {
                result = data;
                break;
            }
        }
    }
    return result;
}
@end
