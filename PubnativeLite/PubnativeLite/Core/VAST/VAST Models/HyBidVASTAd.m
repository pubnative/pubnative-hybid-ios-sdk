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

#import "HyBidVASTAd.h"
#import "HyBidVASTImpressions.h"
#import "HyBidVASTCreatives.h"
#import "HyBidVASTXMLParserHelper.h"
#import "HyBidVASTAdCategory.h"

@interface HyBidVASTAd ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@property (nonatomic) int index;

@property (nonatomic, strong)HyBidVASTXMLParserHelper *parserHelper;

@end

@implementation HyBidVASTAd

- (instancetype)initWithDocumentArray:(NSArray *)array atIndex: (int)index
{
    self = [super init];
    if (self) {
        self.vastDocumentArray = [array mutableCopy];
        self.index = index;
        self.parserHelper = [[HyBidVASTXMLParserHelper alloc] initWithDocumentArray:array];
    }
    return self;
}

- (HyBidVASTAdType)adType
{
    HyBidVASTAdType adType = HyBidVASTAdType_NONE;
    NSString *inlineQuery = @"/VAST/Ad/InLine";
    NSString *wrapperQuery = @"/VAST/Ad/Wrapper";
    
    if ([self.parserHelper getContentForQuery:inlineQuery] != nil) {
        return HyBidVASTAdType_INLINE;
    } else if ([self.parserHelper getContentForQuery:wrapperQuery] != nil) {
        return HyBidVASTAdType_WRAPPER;
    }

    return adType;
}

- (NSString *)id
{
    NSString *query = @"/VAST/Ad";
    NSArray *ids = [self.parserHelper getArrayResultsForQuery: query];
    return [self.parserHelper getContentForAttribute:@"id" inNode:ids[self.index]];
}

- (NSString *)sequence
{
    NSString *query = @"/VAST/Ad";
    NSArray *sequences = [self.parserHelper getArrayResultsForQuery: query];
    return [self.parserHelper getContentForAttribute:@"sequence" inNode:sequences[self.index]];
}

- (BOOL)isConditionalAd
{
    NSString *query = @"/VAST/Ad";
    NSArray *conditionalAds = [self.parserHelper getArrayResultsForQuery: query];
    return [self.parserHelper getContentForAttribute:@"conditionalAd" inNode:conditionalAds[self.index]];
}

- (HyBidVASTAdSystem *)adSystem
{
    HyBidVASTAdSystem *system = [[HyBidVASTAdSystem alloc] initWithDocumentArray:self.vastDocumentArray];
    return system;
}

- (NSString *)adTitle
{
    NSString *query = @"/VAST/Ad/InLine/AdTitle";
    return [self.parserHelper getContentForQuery: query];
}

- (HyBidVASTAdCategory *)category
{
    HyBidVASTAdCategory *category = [[HyBidVASTAdCategory alloc] initWithDocumentArray:self.vastDocumentArray atIndex:self.index];
    return category;
}

- (NSString *)adServingID
{
    NSString *query = @"/VAST/Ad/InLine/AdServingId";
    return [self.parserHelper getContentForQuery: query];
}

- (NSArray<HyBidVASTImpression *> *)impressions
{
    HyBidVASTImpressions *impressions = [[HyBidVASTImpressions alloc] initWithDocumentArray:self.vastDocumentArray];
    return impressions.impressions;
}

- (NSString *)adDescription
{
    NSString *query = @"/VAST/Ad/InLine/Description";
    return [self.parserHelper getContentForQuery: query];
}

- (NSString *)advertiser
{
    NSString *query = @"/VAST/Ad/InLine/Advertiser";
    return [self.parserHelper getContentForQuery: query];
}

- (NSArray<HyBidVASTCreative *> *)creatives
{
    HyBidVASTCreatives *creatives = [[HyBidVASTCreatives alloc] initWithDocumentArray:self.vastDocumentArray];
    return creatives.creatives;
}

- (NSArray<HyBidVASTVerification *> *)adVerifications
{
    NSMutableArray *verifications = [[NSMutableArray alloc] init];
    
    NSString *query = @"//AdVerifications/Verification";
    
    for (int i = 0; i < [[self.parserHelper getArrayResultsForQuery: query] count]; i++) {
        HyBidVASTVerification *verification = [[HyBidVASTVerification alloc] initWithDocumentArray:self.vastDocumentArray atIndex:i];
        [verifications addObject:verification];
    }
    return verifications;
}

@end
