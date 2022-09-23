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
#import "HyBidXMLElementEx.h"
#import "HyBidVASTAdSystem.h"
#import "HyBidVASTImpression.h"
#import "HyBidVASTAdCategory.h"
#import "HyBidVASTVerification.h"
#import "HyBidVASTCreative.h"
#import "HyBidVASTError.h"
#import "HyBidVASTCTAButton.h"

@interface HyBidVASTAdInline : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithInLineXMLElement:(HyBidXMLElementEx *)inLineXmlElement;

/**
 A descriptive name for the system that serves the ad
 */
- (HyBidVASTAdSystem *)adSystem;

/**
 A string that provides a common name for the ad
 */
- (NSString *)adTitle;

/**
 An array of URI that directs the media player to a tracking resource file that the media player must use to notify the ad server when the impression occurs.
 */
- (NSArray<HyBidVASTImpression *> *)impressions;

/**
 A unique or pseudo-unique (long enough to be unique when combined with timestamp data) GUID
 */
- (NSString *)adServingID;

/**
 A string that provides a category code or label that identifies the ad content category.
 */
- (NSArray<HyBidVASTAdCategory *> *)categories;

/**
 A string that provides a long ad description
 */
- (NSString *)description;

/**
 A string that provides the name of the advertiser as defined by the ad serving party
 */
- (NSString *)advertiser;

/**
 The <Error> element contains a URI that the player uses to notify the ad server when errors occur with ad playback.
 */
- (NSArray<HyBidVASTError *> *)errors;

/**
 List of the resources and metadata required to execute third-party measurement code in order to verify creative playback
 */
- (NSArray<HyBidVASTVerification *> *)adVerifications;

/**
 An array of URI that directs the media player to a tracking resource file that the media player must use to notify the ad server when the impression occurs.
 */
- (NSArray<HyBidVASTCreative *> *)creatives;

- (HyBidVASTCTAButton *)ctaButton;

@end
