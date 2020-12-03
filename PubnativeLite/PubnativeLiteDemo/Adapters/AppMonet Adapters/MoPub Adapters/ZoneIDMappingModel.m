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

#import "ZoneIDMappingModel.h"

@interface ZoneIDMappingModel ()

@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *>*>*adSizes;

@end

@implementation ZoneIDMappingModel

- (instancetype)initWithJSONString:(NSString *)jsonString
{
    self = [super init];
    if (self) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        self.appToken = [json objectForKey:@"app_token"];
        
        self.adSizes = [NSMutableDictionary new];
        for (NSString *key in [[json objectForKey:@"ad_sizes"] allKeys]) {
            NSMutableDictionary<NSString *, NSString *>*innerDictionary = [json objectForKey:@"ad_sizes"][key];
            [self.adSizes setObject:innerDictionary forKey:key];
        }
    }
    return self;
}

- (NSString *)getAppToken
{
    return self.appToken;
}

- (NSDictionary<NSString *, NSDictionary<NSString *, NSString *>*>*)getAdSizes
{
    return self.adSizes;
}

@end
