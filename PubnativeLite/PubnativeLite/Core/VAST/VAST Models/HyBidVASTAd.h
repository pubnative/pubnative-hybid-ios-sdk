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
#import "HyBidVASTAdType.h"
#import "HyBidVASTAdSystem.h"
#import "HyBidVASTImpression.h"
#import "HyBidVASTCreative.h"
#import "HyBidVASTVerification.h"
#import "HyBidVASTAdCategory.h"

@interface HyBidVASTAd : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDocumentArray:(NSArray *)array atIndex: (int)index;

/**
 An optional string that identifies the type of ad
 */
- (HyBidVASTAdType)adType;

/**
 An ad server-defined identifier string for the ad
 */
- (NSString *)id;

/**
 A integer greater than zero (0) that identifies the sequence in which an ad should
 */
- (NSString *)sequence;

/**
 A Boolean that identifies a conditional ad
 [Deprecated in VAST 4.1, along with apiFramework]
 */
- (BOOL)isConditionalAd;

// MARK: - VAST Ad Inline Elements

/**
 A descriptive name for the system that serves the ad
 */
- (HyBidVASTAdSystem *)adSystem;

/**
 A string that provides a common name for the ad
 */
- (NSString *)adTitle;

- (HyBidVASTAdCategory *)category;

/**
 A unique or pseudo-unique (long enough to be unique when combined with timestamp data) GUID
 */
- (NSString *)adServingID;

/**
 An array of URI that directs the media player to a tracking resource file that the media player must use to notify the ad server when the impression occurs.
 */
- (NSArray<HyBidVASTImpression *> *)impressions;

/**
 List of the resources and metadata required to execute third-party measurement code in order to verify creative playback
 */
- (NSArray<HyBidVASTVerification *> *)adVerifications;

/**
 A string that provides a long ad description
 */
- (NSString *)adDescription;

/**
 A string that provides the name of the advertiser as defined by the ad serving party
 */
- (NSString *)advertiser;

/**
 An array of URI that directs the media player to a tracking resource file that the media player must use to notify the ad server when the impression occurs.
 */
- (NSArray<HyBidVASTCreative*> *)creatives;

/**
 The <Error> element contains a URI that the player uses to notify the ad server when errors occur with ad playback.
 */
@property (nonatomic) NSArray<NSURL *> *errors;

@end
