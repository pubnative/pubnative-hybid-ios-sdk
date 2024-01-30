//
//  Copyright © 2021 PubNative. All rights reserved.
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
