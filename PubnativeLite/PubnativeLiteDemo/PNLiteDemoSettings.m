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

#import "PNLiteDemoSettings.h"

NSString *const kPNLiteDemoAppToken = @"543027b8e954474cbcd9a98481622a3b";
NSString *const kPNLiteDemoZoneID;
NSString *const kPNLiteDemoMoPubBannerAdUnitID = @"a4eac931d95444f0a95adc77093a22ab";
NSString *const kPNLiteDemoMoPubMRectAdUnitID = @"7f797ff5c287480cbf15e9f1735fb8d7";
NSString *const kPNLiteDemoMoPubInterstitialAdUnitID = @"a91bc5a72fd54888ac248e7656b69b2e";

@implementation PNLiteDemoSettings

- (void)dealloc
{
    self.appToken = nil;
    self.zoneID = nil;
    self.moPubBannerAdUnitID = nil;
    self.moPubMRectAdUnitID = nil;
    self.moPubInterstitialAdUnitID = nil;
}

+ (PNLiteDemoSettings *)sharedInstance
{
    static PNLiteDemoSettings * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PNLiteDemoSettings alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appToken = kPNLiteDemoAppToken;
        self.zoneID = kPNLiteDemoZoneID;
        self.moPubBannerAdUnitID = kPNLiteDemoMoPubBannerAdUnitID;
        self.moPubMRectAdUnitID = kPNLiteDemoMoPubMRectAdUnitID;
        self.moPubInterstitialAdUnitID = kPNLiteDemoMoPubInterstitialAdUnitID;
    }
    return self;
}

@end
