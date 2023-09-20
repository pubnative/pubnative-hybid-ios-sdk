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

static NSString* PNLiteMRAIDSupportsSMS = @"sms";
static NSString* PNLiteMRAIDSupportsTel = @"tel";
static NSString* PNLiteMRAIDSupportsStorePicture = @"storePicture";
static NSString* PNLiteMRAIDSupportsInlineVideo = @"inlineVideo";
static NSString* PNLiteMRAIDSupportsLocation = @"location";


// A delegate for MRAIDView/MRAIDInterstitial to listen for notifications when the following events
// are triggered from a creative: SMS, Telephone call, Play Video (external) and
// saving pictures. If you don't implement this protocol, the default for
// supporting these features for creative will be FALSE.

@protocol HyBidMRAIDServiceDelegate <NSObject>

@optional

// These callbacks are to request other services.
- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString;
- (void)mraidServiceOpenBrowserWithUrlString:(NSString *)urlString;
- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString;
- (void)mraidServiceSendSMSWithUrlString:(NSString *)urlString;
- (void)mraidServiceCallNumberWithUrlString:(NSString *)urlString;
- (void)mraidServiceTrackingEndcardWithUrlString:(NSString *)urlString;

@end
