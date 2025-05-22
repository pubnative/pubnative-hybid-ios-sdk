// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVerificationScriptResource : NSObject

@property (nonatomic, readwrite, strong) NSString *url;
@property (nonatomic, readwrite, strong) NSString *vendorKey;
@property (nonatomic, readwrite, strong) NSString *params;

- (void)hyBidVerificationScriptResource:(NSDictionary *)jsonDic;

@end
