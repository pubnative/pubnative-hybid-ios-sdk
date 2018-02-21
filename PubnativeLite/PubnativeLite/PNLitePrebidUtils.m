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

NSString * const kPNLiteKeyPN = @"m_pn";
NSString * const kPNLiteKeyPN_ZONE_ID = @"pn_zone_id";
NSString * const kPNLiteKeyPN_BID = @"pn_bid";
double const kECPMPointsDivider = 1000.0;

@implementation PNLitePrebidUtils

+ (NSString *)createPrebidKeywordsWithAd:(PNLiteAd *)ad withZoneID:(NSString *)zoneID
{
    NSMutableString *prebid = [[NSMutableString alloc] init];
    [prebid appendString:kPNLiteKeyPN];
    [prebid appendString:@":"];
    [prebid appendString:@"true"];
    [prebid appendString:@","];

    [prebid appendString:kPNLiteKeyPN_ZONE_ID];
    [prebid appendString:@":"];
    [prebid appendString:zoneID];
    [prebid appendString:@","];
    
    [prebid appendString:kPNLiteKeyPN_BID];
    [prebid appendString:@":"];
    [prebid appendString:[NSString stringWithFormat:@"%.3f", [ad.eCPM doubleValue]/kECPMPointsDivider]];
    
    return [NSString stringWithString:prebid];
}

@end
