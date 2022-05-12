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

#import <Foundation/Foundation.h>
#import "HyBidVASTTrackingEvents.h"
#import "HyBidXMLElementEx.h"
#import "HyBidVASTStaticResource.h"
#import "HyBidVASTAdParameters.h"
#import "HyBidVASTCompanionClickThrough.h"
#import "HyBidVASTCompanionClickTracking.h"
#import "HyBidVASTHTMLResource.h"
#import "HyBidVASTIFrameResource.h"

@interface HyBidVASTCompanion : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCompanionXMLElement:(HyBidXMLElementEx *)companionXMLElement;

- (NSString *)id;

- (NSString *)width;

- (NSString *)height;

- (NSString *)assetWidth;

- (NSString *)assetHeight;

- (NSString *)expandedWidth;

- (NSString *)expandedHeight;

// MARK: - Elements

/**
 A URI to the static creative file to be used for the ad component identified in the parent element.
 */
- (NSArray<HyBidVASTStaticResource *> *)staticResources;

- (HyBidVASTAdParameters *)adParameters;

/**
 A URI to the advertiser’s page that the media player opens when the viewer clicks the companion ad.
 */
- (HyBidVASTCompanionClickThrough *)companionClickThrough;

/**
 A URI to a tracking resource file used to track a companion clickthrough
 */
- (NSArray<HyBidVASTCompanionClickTracking *>  *)companionClickTracking;

/**
 The <TrackingEvents> element is a container for <Tracking> elements used to define specific tracking events
 */
- (HyBidVASTTrackingEvents *)trackingEvents;

/**
 A HTML code snippet (within a CDATA element)
 */
- (NSArray<HyBidVASTHTMLResource *> *)htmlResources;

/**
 A URI to the iframe creative file to be used for the ad component identified in the parent element.
 */
- (NSArray<HyBidVASTIFrameResource *> *)iFrameResources;

@end
