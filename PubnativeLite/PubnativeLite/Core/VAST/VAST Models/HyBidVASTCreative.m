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

#import "HyBidVASTCreative.h"

@interface HyBidVASTCreative ()

@property (nonatomic, strong)HyBidXMLElementEx *creativeXMLElement;

@end

@implementation HyBidVASTCreative

- (instancetype)initWithCreativeXMLElement:(HyBidXMLElementEx *)creativeXMLElement
{
    self = [super init];
    if (self) {
        self.creativeXMLElement = creativeXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.creativeXMLElement attribute:@"id"];
}

- (NSString *)adID
{
    return [self.creativeXMLElement attribute:@"adId"];
}

- (NSString *)sequence
{
    return [self.creativeXMLElement attribute:@"sequence"];
}

// MARK: - Elements

- (NSArray<HyBidVASTUniversalAdId *> *)universalAdIds
{
    NSArray<HyBidXMLElementEx *> *result = [self.creativeXMLElement query:@"/UniversalAdId"];
    NSMutableArray<HyBidVASTUniversalAdId *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTUniversalAdId *universalAdId = [[HyBidVASTUniversalAdId alloc] initWithUniversalAdIdXMLElement:result[i]];
        [array addObject:universalAdId];
    }
    
    return array;
}

- (HyBidVASTLinear *)linear
{
    if ([[self.creativeXMLElement query:@"/Linear"] count] > 0) {
        HyBidXMLElementEx *inLineElement = [[self.creativeXMLElement query:@"/Linear"] firstObject];
        return [[HyBidVASTLinear alloc] initWithInLineXMLElement:inLineElement];
    }
    return nil;
}

- (HyBidVASTCompanionAds *)companionAds
{
    if ([[self.creativeXMLElement query:@"/CompanionAds"] count] > 0) {
        HyBidXMLElementEx *companionAdsElement = [[self.creativeXMLElement query:@"/CompanionAds"] firstObject];
        return [[HyBidVASTCompanionAds alloc] initWithCompanionAdsXMLElement:companionAdsElement];
    }
    return nil;
}

@end
