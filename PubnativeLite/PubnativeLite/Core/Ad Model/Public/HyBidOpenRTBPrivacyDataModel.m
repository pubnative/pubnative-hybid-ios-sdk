// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidOpenRTBPrivacyDataModel.h"
#import "HyBidUserDataManager.h"
#import "HyBidRequestParameter.h"

@implementation HyBidOpenRTBPrivacyDataModel

- (instancetype)init{
    self = [super init];
    if(self){
        NSMutableDictionary * privacyDataModel = [NSMutableDictionary dictionary];
        NSString * gdpr = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
        NSString * gpp = [[HyBidUserDataManager sharedInstance] getInternalGPPString];
        NSString * gpp_sid = [[HyBidUserDataManager sharedInstance] getInternalGPPSID];
        NSString * us_privacy = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
        
        if (gdpr) {
            [privacyDataModel setObject: gdpr forKey: HyBidRequestParameter.openRTBgdpr];
        }
        
        if (gpp) {
            [privacyDataModel setObject: gpp forKey: HyBidRequestParameter.openRTBgpp];
        }
        
        if (gpp_sid) {
            [privacyDataModel setObject: [gpp_sid stringByReplacingOccurrencesOfString:@"_" withString:@","] forKey: HyBidRequestParameter.openRTBgpp_sid];
        }
        
        if (us_privacy) {
            [privacyDataModel setObject: us_privacy forKey: HyBidRequestParameter.openRTBus_privacy];
        }
        
        return [@{
            @"regs": @{
                @"ext": privacyDataModel
            }
        } copy];
    }
    return self;
}

@end
