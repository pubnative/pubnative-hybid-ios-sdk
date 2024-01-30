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

extern NSString * const kHyBidErrorDomain;

typedef enum {
    HyBidErrorCodeNoFill = 1,
    HyBidErrorCodeParse = 2,
    HyBidErrorCodeServer = 3,
    HyBidErrorCodeInvalidAsset = 4,
    HyBidErrorCodeUnsupportedAsset = 5,
    HyBidErrorCodeNullAd = 6,
    HyBidErrorCodeInvalidAd = 7,
    HyBidErrorCodeInvalidZoneId = 8,
    HyBidErrorCodeInvalidSignalData = 9,
    HyBidErrorCodeNotInitialised = 10,
    HyBidErrorCodeAuctionNoAd = 11,
    HyBidErrorCodeRenderingBanner = 12,
    HyBidErrorCodeRenderingInterstitial = 13,
    HyBidErrorCodeRenderingRewarded = 14,
    HyBidErrorCodeMraidPlayer = 15,
    HyBidErrorCodeVastPlayer = 16,
    HyBidErrorCodeTrackingUrl = 17,
    HyBidErrorCodeTrackingJS = 18,
    HyBidErrorCodeInvalidUrl = 19,
    HyBidErrorCodeInternal = 20,
    HyBidErrorCodeUnknown = 21,
    HyBidErrorCodeDisabledFormat = 22,
    HyBidErrorCodeDisabledRenderingEngine = 23,
    HyBidExpiredAd = 24,
    HyBidErrorVASTParserSchemaValidation = 25,
    HyBidErrorVASTParserTooManyWrappers = 26,
    HyBidErrorVASTParserNoCompatibleMediaFile = 27,
    HyBidErrorVASTParserNoInternetConnection = 28,
    HyBidErrorVASTParserMovieTooShort = 29,
    HyBidErrorCodeAdFeedbackFormNotLoaded = 30,
    HyBidErrorCodeInvalidHTML = 31,
    HyBidErrorVASTParserNoAdResponse = 32,
    HyBidErrorVASTParserBothAdAndErrorPresentInRootResponse = 33,
    HyBidErrorCodeInvalidCustomCTAIconUrl = 34
} HyBidErrorCode;

@interface NSError (HyBid)

+ (NSError *)errorWithCode:(HyBidErrorCode)code localizedDescription:(NSString *)description;

+ (instancetype)hyBidNoFill;
+ (instancetype)hyBidParseError;
+ (instancetype)hyBidServerError;
+ (instancetype)hyBidServerErrorWithMessage:(NSString *) message;
+ (instancetype)hyBidInvalidAsset;
+ (instancetype)hyBidUnsupportedAsset;
+ (instancetype)hyBidNullAd;
+ (instancetype)hyBidInvalidAd;
+ (instancetype)hyBidInvalidZoneId;
+ (instancetype)hyBidInvalidSignalData;
+ (instancetype)hyBidNotInitialised;
+ (instancetype)hyBidAuctionNoAd;
+ (instancetype)hyBidRenderingBanner;
+ (instancetype)hyBidRenderingInterstitial;
+ (instancetype)hyBidRenderingRewarded;
+ (instancetype)hyBidMraidPlayer;
+ (instancetype)hyBidVastPlayer;
+ (instancetype)hyBidTrackingUrl;
+ (instancetype)hyBidTrackingJS;
+ (instancetype)hyBidInvalidUrl;
+ (instancetype)hyBidInternalError;
+ (instancetype)hyBidUnknownError;
+ (instancetype)hyBidDisabledFormatError;
+ (instancetype)hyBidDisabledRenderingEngineError;
+ (instancetype)hyBidExpiredAd;
+ (instancetype)hyBidVASTParserSchemaValidationError;
+ (instancetype)hyBidVASTParserTooManyWrappersError;
+ (instancetype)hyBidVASTParserNoCompatibleMediaFileError;
+ (instancetype)hyBidVASTParserNoInternetConnectionError;
+ (instancetype)hyBidVASTParserMovieTooShortError;
+ (instancetype)hyBidAdFeedbackFormNotLoaded;
+ (instancetype)hyBidInvalidHTML;
+ (instancetype)hyBidVASTNoAdResponse;
+ (instancetype)hyBidVASTBothAdAndErrorPresentInRootResponse;
+ (instancetype)hyBidInvalidCustomCTAIconUrl;

@end
