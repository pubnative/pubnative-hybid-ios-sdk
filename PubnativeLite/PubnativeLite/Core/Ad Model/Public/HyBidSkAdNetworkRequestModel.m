// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
    return [HyBidSDKConfig sharedConfig].appID;
}

- (NSString *)getSkAdNetworkVersion
{
    if (@available(iOS 16.1, *)) {
        return @"4.0";
    } else if (@available(iOS 14.6, *)) {
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
