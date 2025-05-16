// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidBaseModel.h"

@interface HyBidSkAdNetworkModel : HyBidBaseModel

@property (nonatomic, strong) NSDictionary *productParameters;

- (instancetype)initWithParameters:(NSDictionary *)productParams;
- (NSDictionary *)getStoreKitParameters;
- (BOOL)isSKAdNetworkIDVisible:(NSDictionary*) productParams;

- (BOOL)areProductParametersValid:(NSDictionary *)dict;
- (BOOL)checkBasicParameters:(NSDictionary *)dict supportMultipleFidelities:(BOOL)supportsMultipleFidelities;
- (BOOL)checkV2Parameters:(NSDictionary *)dict;
- (BOOL)checkV2_2_Parameters:(NSDictionary *)dict supportMultipleFidelities:(BOOL)supportsMultipleFidelities;
- (BOOL)checkV4_0_Parameters:(NSDictionary *)dict;
@end


