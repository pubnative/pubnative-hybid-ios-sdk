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

#import <Foundation/Foundation.h>

@interface PNLiteData : NSObject

+ (NSString *)text;
+ (NSString *)vast;
+ (NSString *)number;
+ (NSString *)url;
+ (NSString *)js;
+ (NSString *)html;
+ (NSString *)width;
+ (NSString *)height;
+ (NSString *)jsonData;
+ (NSString *)skoverlayEnabled;
+ (NSString *)pcSKoverlayEnabled;
+ (NSString *)audioState;
+ (NSString *)endcardEnabled;
+ (NSString *)pcEndcardEnabled;
+ (NSString *)customEndcardEnabled;
+ (NSString *)customEndCardInputValue;
+ (NSString *)endcardCloseDelay;
+ (NSString *)pcEndcardCloseDelay;
+ (NSString *)bcEndcardCloseDelay;
+ (NSString *)nativeCloseButtonDelay;
+ (NSString *)interstitialHtmlSkipOffset;
+ (NSString *)pcInterstitialHtmlSkipOffset;
+ (NSString *)rewardedHtmlSkipOffset;
+ (NSString *)pcRewardedHtmlSkipOffset;
+ (NSString *)videoSkipOffset;
+ (NSString *)pcVideoSkipOffset;
+ (NSString *)bcVideoSkipOffset;
+ (NSString *)rewardedVideoSkipOffset;
+ (NSString *)pcRewardedVideoSkipOffset;
+ (NSString *)bcRewardedVideoSkipOffset;
+ (NSString *)closeInterstitialAfterFinish;
+ (NSString *)closeRewardedAfterFinish;
+ (NSString *)fullscreenClickability;
+ (NSString *)impressionTracking;
+ (NSString *)minVisibleTime;
+ (NSString *)minVisiblePercent;
+ (NSString *)contentInfoURL;
+ (NSString *)contentInfoIconURL;
+ (NSString *)contentInfoIconClickAction;
+ (NSString *)contentInfoDisplay;
+ (NSString *)contentInfoText;
+ (NSString *)contentInfoHorizontalPosition;
+ (NSString *)contentInfoVerticalPosition;
+ (NSString *)mraidExpand;
+ (NSString *)customEndcardDisplay;
+ (NSString *)creativeAutoStorekitEnabled;
+ (NSString *)customCtaEnabled;
+ (NSString *)customCtaDelay;
+ (NSString *)customCtaInputValue;
+ (NSString *)sdkAutoStorekitEnabled;
+ (NSString *)pcSDKAutoStorekitEnabled;
+ (NSString *)sdkAutoStorekitDelay;
+ (NSString *)atomEnabled;
+ (NSString *)itunesIdValue;
+ (NSString *)reducedIconSizes;
+ (NSString *)reducedIconSizesInputValue;
+ (NSString *)hideControls;

@end
