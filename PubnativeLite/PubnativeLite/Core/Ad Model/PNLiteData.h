// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
+ (NSString *)boolean;
+ (NSString *)skOverlayEnabled;
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
+ (NSString *)itunesIdValue;
+ (NSString *)reducedIconSizes;
+ (NSString *)reducedIconSizesInputValue;
+ (NSString *)hideControls;
+ (NSString *)navigationMode;
+ (NSString *)navigationModeInputValue;
+ (NSString *)landingPage;
+ (NSString *)landingPageInputValue;
+ (NSString *)ctaButtonSize;
+ (NSString *)ctaButtonSizeInputValue;
+ (NSString *)ctaButtonLocation;
+ (NSString *)ctaButtonLocationInputValue;

@end
