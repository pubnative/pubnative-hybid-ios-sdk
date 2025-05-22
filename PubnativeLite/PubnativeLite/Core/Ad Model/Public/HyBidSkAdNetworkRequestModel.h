// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

 #import <Foundation/Foundation.h>

 @interface HyBidSkAdNetworkRequestModel : NSObject

 - (NSString *)getAppID;
 - (NSString *)getSkAdNetworkVersion;
 - (NSArray *)getSkAdNetworkAdNetworkIDsArray;
 - (NSString *)getSkAdNetworkAdNetworkIDsString;

 @end
