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

#import "HyBidDisplayManager.h"
#import"HyBidConstants.h"

NSString * const DISPLAY_MANAGER_NAME = @"HyBid";
NSString * const DISPLAY_MANAGER_ENGINE = @"sdkios";

@implementation HyBidDisplayManager

+ (NSString*)getDisplayManagerVersion {
    return [HyBidDisplayManager setDisplayManager:IN_APP_BIDDING];
}

+ (NSString *)getDisplayManagerVersionWithIntegrationType:(IntegrationType)integrationType
{
    return [self getDisplayManagerVersionWithIntegrationType:integrationType andWithMediationVendor:nil];
}

+ (NSString *)getDisplayManagerVersionWithIntegrationType:(IntegrationType)integrationType andWithMediationVendor:(NSString *)mediationVendor
{
    NSString *mediationValue = @"";
    
    if (mediationVendor != nil && [mediationVendor length] > 0) {
        mediationValue = [[NSString alloc] initWithFormat:@"_%@", mediationVendor];
    }
    
    return [[NSString alloc] initWithFormat:@"%@_%@%@_%@", DISPLAY_MANAGER_ENGINE, [HyBidIntegrationType integrationTypeToString:integrationType], mediationValue, HYBID_SDK_VERSION];
}

+ (NSString*)setDisplayManager:(IntegrationType)integrationType {
    return [NSString stringWithFormat:@"%@_%@_%@", DISPLAY_MANAGER_ENGINE, [HyBidIntegrationType integrationTypeToString:integrationType] ,HYBID_SDK_VERSION];
}

+ (NSString*)getDisplayManager {
    return DISPLAY_MANAGER_NAME;
}

@end
