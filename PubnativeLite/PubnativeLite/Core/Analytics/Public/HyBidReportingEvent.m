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

#import "HyBidReportingEvent.h"
#import "HyBidReporting.h"

@implementation HyBidReportingEvent


- (instancetype)initWith:(NSString *)eventType
                adFormat:(NSString *)adFormat
              properties:(NSDictionary<NSString *,NSObject *> *)properties {
    self = [super init];
    if (self) {
        self.eventType = eventType;
        self.properties = (properties != nil) ? self.properties = properties : [[NSDictionary alloc]init];
        NSMutableDictionary* mutuableProperties = [[NSMutableDictionary alloc]initWithDictionary:self.properties];
        [mutuableProperties setValue:eventType forKey:HyBidReportingCommon.EVENT_TYPE];
        [mutuableProperties setValue:adFormat forKey:HyBidReportingCommon.AD_FORMAT];
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        [mutuableProperties setValue:[[NSString alloc]initWithFormat:@"%lld", milliseconds]  forKey:HyBidReportingCommon.TIMESTAMP];
        self.properties = [mutuableProperties copy];
    }
    return self;
}

- (NSString *)toJSON {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.properties options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
