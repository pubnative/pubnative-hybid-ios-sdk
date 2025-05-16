// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "PNLiteAdRequestModel.h"
#import "HyBidIntegrationType.h"
#import "HyBidAdSize.h"

@interface PNLiteAdFactory : NSObject

@property (nonatomic, strong) NSString *mediationVendor;

- (PNLiteAdRequestModel *)createAdRequestWithZoneID:(NSString *)zoneID
                                       withAppToken:(NSString *)apptoken
                                         withAdSize:(HyBidAdSize *)adSize
                         withSupportedAPIFrameworks:(NSArray<NSString *> *)supportedAPIFrameworks
                                withIntegrationType:(IntegrationType)integrationType
                                         isRewarded:(BOOL)isRewarded
                                     isUsingOpenRTB:(BOOL)isUsingOpenRTB
                                mediationVendorName: (NSString*) mediationVendorName;

@end
