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

#import "HyBidSkAdNetworkRequestModel.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidSkAdNetworkRequestModel ()

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *skAdNetworkVersion;
@property (nonatomic, strong) NSString *skAdNetworkAdNetworkIDs;

@end

@implementation HyBidSkAdNetworkRequestModel

- (NSString *)getAppID
{
    return [HyBidSettings sharedInstance].appID;
}

- (NSString *)getSkAdNetworkVersion
{
    if (@available(iOS 14.6, *)) {
        return @"3.0";
    } else if (@available(iOS 14.5, *)) {
        return @"2.2";
    } else if (@available(iOS 14, *)) {
        return @"2.0";
    } else {
        return @"1.0";
    }
}

- (NSArray *)getSkAdNetworkAdNetworkIDsArray {
    NSArray *networkItems = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SKAdNetworkItems"];
    
    if (networkItems == NULL) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"The key `SKAdNetworkItems` could not be found in `info.plist` file of the app. Please add the required item and try again."];
    }
    
    NSMutableArray *adIDs = [[NSMutableArray alloc] init];
    for (int i = 0; i < [networkItems count]; i++) {
        NSDictionary *dict = networkItems[i];
        NSString *value = dict[@"SKAdNetworkIdentifier"];
        [adIDs addObject:value];
    }
    
    return adIDs;
}
-(NSString *)getSkAdNetworkAdNetworkIDsString {
    NSArray *adIDs = [self getSkAdNetworkAdNetworkIDsArray];
    return [adIDs componentsJoinedByString:@","];
}

@end
