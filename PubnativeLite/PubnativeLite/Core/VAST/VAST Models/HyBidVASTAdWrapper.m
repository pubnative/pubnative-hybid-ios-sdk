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

#import "HyBidVASTAdWrapper.h"
#import "HyBidXMLElementEx.h"
#import "HyBidVASTAdSystem.h"
#import "HyBidVASTImpression.h"
#import "HyBidVASTAdCategory.h"
#import "HyBidVASTVerification.h"
#import "HyBidVASTCreative.h"
#import "HyBidVASTError.h"
#import "HyBidVASTCTAButton.h"

@interface HyBidVASTAdWrapper ()

@property (nonatomic, strong)HyBidXMLElementEx *wrapperXmlElement;

@property (nonatomic, strong)NSArray<HyBidXMLElementEx *> *extensions;

@end

@implementation HyBidVASTAdWrapper

- (instancetype)initWithWrapperXMLElement:(HyBidXMLElementEx *)wrapperXmlElement
{
    self = [super init];
    if (self) {
        self.wrapperXmlElement = wrapperXmlElement;
    }
    return self;
}

- (HyBidVASTAdSystem *)adSystem
{
    if ([[self.wrapperXmlElement query:@"/AdSystem"] count] > 0) {
        HyBidXMLElementEx *adSystemElement = [[self.wrapperXmlElement query:@"/AdSystem"] firstObject];
        HyBidVASTAdSystem *system = [[HyBidVASTAdSystem alloc] initWithAdSystemXMLElement:adSystemElement];
        return system;
    }
    return nil;
}

- (NSString *)adTitle
{
    if ([[self.wrapperXmlElement query:@"/AdTitle"] count] > 0) {
        HyBidXMLElementEx* element= [[self.wrapperXmlElement query:@"/AdTitle"] firstObject];
        return [element value];
    }
    return nil;
}

- (NSString *)adServingID
{
    if ([[self.wrapperXmlElement query:@"/AdServingId"] count] > 0) {
        HyBidXMLElementEx* element= [[self.wrapperXmlElement query:@"/AdServingId"] firstObject];
        return [element value];
    }
    return nil;
}

- (NSString *)description
{
    if ([[self.wrapperXmlElement query:@"/Description"] count] > 0) {
        HyBidXMLElementEx* element= [[self.wrapperXmlElement query:@"/Description"] firstObject];
        return [element value];
    }
    return nil;
}

- (NSString *)advertiser
{
    if ([[self.wrapperXmlElement query:@"/Advertiser"] count] > 0) {
        HyBidXMLElementEx* element= [[self.wrapperXmlElement query:@"/Advertiser"] firstObject];
        return [element value];
    }
    return nil;
}

- (NSArray<HyBidVASTImpression *> *)impressions
{
    NSArray<HyBidXMLElementEx *> *impressionElementsArray = [self.wrapperXmlElement query:@"/Impression"];
    NSMutableArray<HyBidVASTImpression *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [impressionElementsArray count]; i++) {
        HyBidVASTImpression *impression = [[HyBidVASTImpression alloc] initWithImpressionXMLElement:impressionElementsArray[i]];
        [array addObject:impression];
    }
    
    return array;
}

- (NSArray<HyBidVASTAdCategory *> *)categories
{
    NSArray<HyBidXMLElementEx *> *categoryElementsArray = [self.wrapperXmlElement query:@"/Category"];
    NSMutableArray<HyBidVASTAdCategory *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [categoryElementsArray count]; i++) {
        HyBidVASTAdCategory *category = [[HyBidVASTAdCategory alloc] initWithCategoryXMLElement:categoryElementsArray[i]];
        [array addObject:category];
    }
    
    return array;
}

- (NSArray<HyBidVASTCreative *> *)creatives
{
    NSMutableArray<HyBidVASTCreative *> *array = [[NSMutableArray alloc] init];
    
    if ([[self.wrapperXmlElement query:@"/Creatives"] count] > 0) {
        HyBidXMLElementEx *creativesElement = [[self.wrapperXmlElement query:@"/Creatives"] firstObject];
        
        NSString *query = @"/Creative";
        NSArray<HyBidXMLElementEx *> *result = [creativesElement query:query];
        
        for (int i = 0; i < [result count]; i++) {
            HyBidVASTCreative *creative = [[HyBidVASTCreative alloc] initWithCreativeXMLElement:result[i]];
            [array addObject:creative];
        }
    }
    
    return array;
}

- (NSArray<HyBidVASTVerification *> *)adVerifications
{
    NSMutableArray<HyBidVASTVerification *> *array = [[NSMutableArray alloc] init];
    
    if ([[self.wrapperXmlElement query:@"/AdVerifications"] count] > 0) {
        [array addObjectsFromArray:[self fetchAdVerificationsFrom:self.wrapperXmlElement]];
    } else if ([self.extensions count] > 0) {
        for (HyBidXMLElementEx *extension in self.extensions) {
            if ([[extension query:@"/AdVerifications"] count] > 0) {
                [array addObjectsFromArray: [self fetchAdVerificationsFrom:extension]];
            }
        }
    }
    
    return array;
}

- (HyBidVASTCTAButton *)ctaButton
{
    for (HyBidXMLElementEx *extension in self.extensions) {
        if ([[extension attribute:@"type"] isEqualToString:@"Verve"]) {
            HyBidXMLElementEx *ctaXmlElement = [[extension query:@"/VerveCTAButton"] firstObject];
            
            if (ctaXmlElement != nil) {
                HyBidVASTCTAButton *ctaButton = [[HyBidVASTCTAButton alloc] initWithCTAButtonXMLElement:ctaXmlElement];
                return ctaButton;
            }
        }
    }

    return nil;
}

- (NSArray<HyBidVASTError *> *)errors
{
    NSArray<HyBidXMLElementEx *> *result = [self.wrapperXmlElement query:@"/Error"];
    NSMutableArray<HyBidVASTError *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTError *error = [[HyBidVASTError alloc] initWithErrorXMLElement:result[i]];
        [array addObject:error];
    }
    
    return array;
}

// MARK: - Helpers

- (NSArray<HyBidVASTVerification *> *)fetchAdVerificationsFrom:(HyBidXMLElementEx *)xmlBlock
{
    NSMutableArray<HyBidVASTVerification *> *array = [[NSMutableArray alloc] init];
    
    HyBidXMLElementEx *adVerificationsElement = [[xmlBlock query:@"/AdVerifications"] firstObject];
    
    NSString *query = @"/Verification";
    NSArray<HyBidXMLElementEx *> *result = [adVerificationsElement query:query];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTVerification *verification = [[HyBidVASTVerification alloc] initWithVerificationXMLElement:result[i]];
        [array addObject:verification];
    }
    
    return array;
}

@end
