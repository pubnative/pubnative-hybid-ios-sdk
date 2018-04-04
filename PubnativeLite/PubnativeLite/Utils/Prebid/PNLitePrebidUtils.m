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

#import "PNLitePrebidUtils.h"

NSString *const kPNLiteKeyPN = @"m_pn";
NSString *const kPNLiteKeyPN_ZONE_ID = @"pn_zone_id";
NSString *const kPNLiteKeyPN_BID = @"pn_bid";
double const kECPMPointsDivider = 1000.0;

@implementation PNLitePrebidUtils

+ (NSString *)createPrebidKeywordsStringWithAd:(PNLiteAd *)ad withZoneID:(NSString *)zoneID
{
    NSMutableString *prebidString = [[NSMutableString alloc] init];
    [prebidString appendString:kPNLiteKeyPN];
    [prebidString appendString:@":"];
    [prebidString appendString:@"true"];
    [prebidString appendString:@","];

    [prebidString appendString:kPNLiteKeyPN_ZONE_ID];
    [prebidString appendString:@":"];
    [prebidString appendString:zoneID];
    [prebidString appendString:@","];
    
    [prebidString appendString:kPNLiteKeyPN_BID];
    [prebidString appendString:@":"];
    [prebidString appendString:[self eCPMFromAd:ad]];
    
    return [NSString stringWithString:prebidString];
}

+ (NSMutableDictionary *)createPrebidKeywordsDictionaryWithAd:(PNLiteAd *)ad withZoneID:(NSString *)zoneID
{
    NSMutableDictionary *prebidDictionary = [NSMutableDictionary dictionary];
    [prebidDictionary setValue:@"true" forKey:kPNLiteKeyPN];
    [prebidDictionary setValue:zoneID forKey:kPNLiteKeyPN_ZONE_ID];
    [prebidDictionary setValue:[self eCPMFromAd:ad] forKey:kPNLiteKeyPN_BID];
    return prebidDictionary;
}

+ (NSString *)eCPMFromAd:(PNLiteAd *)ad
{
    return [NSString stringWithFormat:@"%.3f", [ad.eCPM doubleValue]/kECPMPointsDivider];
}

@end
