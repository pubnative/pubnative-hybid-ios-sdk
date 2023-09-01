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

+ (NSString *)appToken                      { return @"apptoken"; }
+ (NSString *)os                            { return @"os"; }
+ (NSString *)osVersion                     { return @"osver"; }
+ (NSString *)deviceOsVersion               { return @"osv"; }
+ (NSString *)deviceModel                   { return @"devicemodel"; }
+ (NSString *)deviceWidth                   { return @"dw"; }
+ (NSString *)deviceHeight                  { return @"dh"; }
+ (NSString *)deviceModelIdentifier         { return @"hwv"; }
+ (NSString *)deviceMake                    { return @"make"; }
+ (NSString *)deviceType                    { return @"devicetype"; }
+ (NSString *)screenWidthInPixels           { return @"w"; }
+ (NSString *)screenHeightInPixels          { return @"h"; }
+ (NSString *)pxRatio                       { return @"pxratio"; }
+ (NSString *)geoFetch                      { return @"geofetch"; }
+ (NSString *)js                            { return @"js"; }
+ (NSString *)language                      { return @"language"; }
+ (NSString *)langb                         { return @"langb"; }
+ (NSString *)carrier                       { return @"carrier"; }
+ (NSString *)carrierMCCMNC                 { return @"mccmnc"; }
+ (NSString *)connectiontype                { return @"connectiontype"; }
+ (NSString *)orientation                   { return @"scro"; }
+ (NSString *)dnt                           { return @"dnt"; }
+ (NSString *)locale                        { return @"locale"; }
+ (NSString *)adCount                       { return @"adcount"; }
+ (NSString *)zoneId                        { return @"zoneid"; }
+ (NSString *)lat                           { return @"lat"; }
+ (NSString *)lon                           { return @"long"; }
+ (NSString *)gender                        { return @"gender"; }
+ (NSString *)age                           { return @"age"; }
+ (NSString *)keywords                      { return @"keywords"; }
+ (NSString *)appVersion                    { return @"appver"; }
+ (NSString *)test                          { return @"test"; }
+ (NSString *)video                         { return @"video"; }
+ (NSString *)metaField                     { return @"mf"; }
+ (NSString *)assetsField                   { return @"af"; }
+ (NSString *)idfa                          { return @"idfa"; }
+ (NSString *)idfamd5                       { return @"idfamd5"; }
+ (NSString *)idfasha1                      { return @"idfasha1"; }
+ (NSString *)coppa                         { return @"coppa"; }
+ (NSString *)assetLayout                   { return @"al"; }
+ (NSString *)bundleId                      { return @"bundleid"; }
+ (NSString *)displayManager                { return @"displaymanager"; }
+ (NSString *)displayManagerVersion         { return @"displaymanagerver"; }
+ (NSString *)usprivacy                     { return @"usprivacy"; }
+ (NSString *)userconsent                   { return @"userconsent"; }
+ (NSString *)width                         { return @"w"; }
+ (NSString *)height                        { return @"h"; }
+ (NSString *)supportedAPIFrameworks        { return @"api"; }
+ (NSString *)identifierOfOMSDKIntegration  { return @"omidpn"; }
+ (NSString *)versionOfOMSDKIntegration     { return @"omidpv"; }
+ (NSString *)identifierForVendor           { return @"ifv"; }
+ (NSString *)rewardedVideo                 { return @"rv"; }
+ (NSString *)protocol                      { return @"protocol"; }
+ (NSString *)api                           { return @"api"; }
+ (NSString *)appTrackingTransparency       { return @"atts"; }
+ (NSString *)sessionDuration               { return @"sessionduration"; }
+ (NSString *)impressionDepth               { return @"impdepth"; }
+ (NSString *)ageOfApp                      { return @"ageofapp"; }
+ (NSString *)accuracy                      { return @"accuracy"; }
+ (NSString *)utcoffset                     { return @"utcoffset"; }
+ (NSString *)charging                      { return @"charging"; }
+ (NSString *)batteryLevel                  { return @"batterylevel"; }
+ (NSString *)batterySaver                  { return @"batterysaver"; }
+ (NSString *)interstitial                  { return @"instl"; }
+ (NSString *)clickbrowser                  { return @"clickbrowser"; }
+ (NSString *)topframe                      { return @"topframe"; }
+ (NSString *)mimes                         { return @"mimes"; }
+ (NSString *)expandDirection               { return @"expdir"; }
+ (NSString *)pos                           { return @"pos"; }
+ (NSString *)videomimes                    { return @"videomimes"; }
+ (NSString *)placement                     { return @"placement"; }
+ (NSString *)placementSubtype              { return @"plcmt"; }
+ (NSString *)linearity                     { return @"linearity"; }
+ (NSString *)boxingallowed                 { return @"boxingallowed"; }
+ (NSString *)playbackmethod                { return @"playbackmethod"; }
+ (NSString *)playbackend                   { return @"playbackend"; }
+ (NSString *)clickType                     { return @"clktype"; }
+ (NSString *)delivery                      { return @"delivery"; }
+ (NSString *)videoPosition                 { return @"videopos"; }
+ (NSString *)mraidendcard                  { return @"mraidendcard"; }
+ (NSString *)darkmode                      { return @"darkmode"; }
+ (NSString *)inputLanguage                 { return @"inputlanguage"; }
+ (NSString *)airplaneMode                  { return @"airplane"; }
+ (NSString *)totalDiskSpace                { return @"totaldisk"; }
+ (NSString *)availableDiskSpace            { return @"diskspace"; }

#pragma mark - SKAdNetwork parameters
+ (NSString *)skAdNetworkVersion            { return @"skadn_version"; }
+ (NSString *)skAdNetworkAppID              { return @"skadn_sourceapp"; }
+ (NSString *)skAdNetworkAdNetworkIDs       { return @"skadnetids"; }

#pragma mark - OpenRTB API
+ (NSString *)ip                            { return @"ip"; }

#pragma mark - Voyager parameters
+ (NSString *)vg                            { return @"vg"; }

@end
