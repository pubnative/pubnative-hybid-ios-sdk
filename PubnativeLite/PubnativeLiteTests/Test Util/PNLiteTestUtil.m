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

#import "PNLiteTestUtil.h"
#import "HyBidDataModel.h"

@implementation PNLiteTestUtil

+ (instancetype)sharedInstance
{
    static PNLiteTestUtil *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PNLiteTestUtil alloc] init];
    });
    return _instance;
}

- (NSArray *)createMockImpressionBeaconArray
{
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"validImpressionURL",@"url", nil];
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"impression", @"type", urlDictionary, @"data", nil];
    HyBidDataModel * dataModel = [[HyBidDataModel alloc] initWithDictionary:dataDictionary];
    return [[NSArray array] arrayByAddingObject:dataModel];
}

- (NSArray *)createMockClickBeaconArray
{
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"validClickURL",@"url", nil];
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"click", @"type", urlDictionary, @"data", nil];
    HyBidDataModel * dataModel = [[HyBidDataModel alloc] initWithDictionary:dataDictionary];
    return [[NSArray array] arrayByAddingObject:dataModel];
}

@end
