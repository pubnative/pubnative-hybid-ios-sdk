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

#import "HyBidRequestParameter.h"

@implementation HyBidRequestParameter

+ (NSString * _Nonnull)appToken                      { return @"apptoken"; }
+ (NSString * _Nonnull)os                            { return @"os"; }
+ (NSString * _Nonnull)osVersion                     { return @"osver"; }
+ (NSString * _Nonnull)deviceModel                   { return @"devicemodel"; }
+ (NSString * _Nonnull)deviceWidth                   { return @"dw"; }
+ (NSString * _Nonnull)deviceHeight                  { return @"dh"; }
+ (NSString * _Nonnull)deviceModelIdentifier         { return @"hwv"; }
+ (NSString * _Nonnull)deviceMake                    { return @"make"; }
+ (NSString * _Nonnull)deviceType                    { return @"devicetype"; }
+ (NSString * _Nonnull)screenWidthInPixels           { return @"w"; }
+ (NSString * _Nonnull)screenHeightInPixels          { return @"h"; }
+ (NSString * _Nonnull)pxRatio                       { return @"pxratio"; }
+ (NSString * _Nonnull)geoFetch                      { return @"geofetch"; }
+ (NSString * _Nonnull)js                            { return @"js"; }
+ (NSString * _Nonnull)language                      { return @"language"; }
+ (NSString * _Nonnull)langb                         { return @"langb"; }
+ (NSString * _Nonnull)carrier                       { return @"carrier"; }
+ (NSString * _Nonnull)carrierMCCMNC                 { return @"mccmnc"; }
+ (NSString * _Nonnull)connectiontype                { return @"connectiontype"; }
+ (NSString * _Nonnull)orientation                   { return @"scro"; }
+ (NSString * _Nonnull)dnt                           { return @"dnt"; }
+ (NSString * _Nonnull)locale                        { return @"locale"; }
+ (NSString * _Nonnull)adCount                       { return @"adcount"; }
+ (NSString * _Nonnull)zoneId                        { return @"zoneid"; }
+ (NSString * _Nonnull)lat                           { return @"lat"; }
+ (NSString * _Nonnull)lon                           { return @"long"; }
+ (NSString * _Nonnull)gender                        { return @"gender"; }
+ (NSString * _Nonnull)age                           { return @"age"; }
+ (NSString * _Nonnull)keywords                      { return @"keywords"; }
+ (NSString * _Nonnull)appVersion                    { return @"appver"; }
+ (NSString * _Nonnull)test                          { return @"test"; }
+ (NSString * _Nonnull)video                         { return @"video"; }
+ (NSString * _Nonnull)metaField                     { return @"mf"; }
+ (NSString * _Nonnull)assetsField                   { return @"af"; }
+ (NSString * _Nonnull)idfa                          { return @"idfa"; }
+ (NSString * _Nonnull)idfamd5                       { return @"idfamd5"; }
+ (NSString * _Nonnull)idfasha1                      { return @"idfasha1"; }
+ (NSString * _Nonnull)coppa                         { return @"coppa"; }
+ (NSString * _Nonnull)assetLayout                   { return @"al"; }
+ (NSString * _Nonnull)bundleId                      { return @"bundleid"; }
+ (NSString * _Nonnull)displayManager                { return @"displaymanager"; }
+ (NSString * _Nonnull)displayManagerVersion         { return @"displaymanagerver"; }
+ (NSString * _Nonnull)usprivacy                     { return @"usprivacy"; }
+ (NSString * _Nonnull)userconsent                   { return @"userconsent"; }
+ (NSString * _Nonnull)gppstring                     { return @"gpp"; }
+ (NSString * _Nonnull)gppsid                        { return @"gppsid"; }
+ (NSString * _Nonnull)width                         { return @"w"; }
+ (NSString * _Nonnull)height                        { return @"h"; }
+ (NSString * _Nonnull)supportedAPIFrameworks        { return @"api"; }
+ (NSString * _Nonnull)identifierOfOMSDKIntegration  { return @"omidpn"; }
+ (NSString * _Nonnull)versionOfOMSDKIntegration     { return @"omidpv"; }
+ (NSString * _Nonnull)identifierForVendor           { return @"ifv"; }
+ (NSString * _Nonnull)rewardedVideo                 { return @"rv"; }
+ (NSString * _Nonnull)protocol                      { return @"protocols"; }
+ (NSString * _Nonnull)api                           { return @"api"; }
+ (NSString * _Nonnull)appTrackingTransparency       { return @"atts"; }
+ (NSString * _Nonnull)sessionDuration               { return @"sessionduration"; }
+ (NSString * _Nonnull)impressionDepth               { return @"impdepth"; }
+ (NSString * _Nonnull)ageOfApp                      { return @"ageofapp"; }
+ (NSString * _Nonnull)accuracy                      { return @"accuracy"; }
+ (NSString * _Nonnull)utcoffset                     { return @"utcoffset"; }
+ (NSString * _Nonnull)charging                      { return @"charging"; }
+ (NSString * _Nonnull)batteryLevel                  { return @"batterylevel"; }
+ (NSString * _Nonnull)batterySaver                  { return @"batterysaver"; }
+ (NSString * _Nonnull)interstitial                  { return @"instl"; }
+ (NSString * _Nonnull)clickbrowser                  { return @"clickbrowser"; }
+ (NSString * _Nonnull)topframe                      { return @"topframe"; }
+ (NSString * _Nonnull)mimes                         { return @"mimes"; }
+ (NSString * _Nonnull)expandDirection               { return @"expdir"; }
+ (NSString * _Nonnull)pos                           { return @"pos"; }
+ (NSString * _Nonnull)videomimes                    { return @"videomimes"; }
+ (NSString * _Nonnull)placement                     { return @"placement"; }
+ (NSString * _Nonnull)placementSubtype              { return @"plcmt"; }
+ (NSString * _Nonnull)linearity                     { return @"linearity"; }
+ (NSString * _Nonnull)boxingallowed                 { return @"boxingallowed"; }
+ (NSString * _Nonnull)playbackmethod                { return @"playbackmethod"; }
+ (NSString * _Nonnull)playbackend                   { return @"playbackend"; }
+ (NSString * _Nonnull)clickType                     { return @"clktype"; }
+ (NSString * _Nonnull)delivery                      { return @"delivery"; }
+ (NSString * _Nonnull)videoPosition                 { return @"videopos"; }
+ (NSString * _Nonnull)mraidendcard                  { return @"mraidendcard"; }
+ (NSString * _Nonnull)darkmode                      { return @"darkmode"; }
+ (NSString * _Nonnull)airplaneMode                  { return @"airplane"; }
+ (NSString * _Nonnull)btype                         { return @"btype"; }

#pragma mark - SKAdNetwork parameters
+ (NSString * _Nonnull)skAdNetworkVersion            { return @"skadn_version"; }
+ (NSString * _Nonnull)skAdNetworkAppID              { return @"skadn_sourceapp"; }
+ (NSString * _Nonnull)skAdNetworkAdNetworkIDs       { return @"skadnetids"; }

#pragma mark - OpenRTB API
+ (NSString * _Nonnull)ip                            { return @"ip"; }
+ (NSString * _Nonnull)userAgent                     { return @"ua"; }
+ (NSString * _Nonnull)uuid                          { return @"id"; }
+ (NSString * _Nonnull)app                           { return @"app"; }
+ (NSString * _Nonnull)device                        { return @"device"; }
+ (NSString * _Nonnull)imp                           { return @"imp"; }
+ (NSString * _Nonnull)extension                     { return @"ext"; }
+ (NSString * _Nonnull)geolocation                   { return @"geo"; }

#pragma mark - Voyager parameters
+ (NSString * _Nonnull)vg                            { return @"vg"; }

#pragma mark - DSPv1 / OpenRTB parameters
+ (NSString * _Nonnull)openRTBgdpr                          { return @"gdpr"; }
+ (NSString * _Nonnull)openRTBgpp                           { return @"gpp"; }
+ (NSString * _Nonnull)openRTBgpp_sid                       { return @"gpp_sid"; }
+ (NSString * _Nonnull)openRTBus_privacy                    { return @"us_privacy"; }
@end
