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

#import "HyBidVASTEndCardManager.h"

@interface HyBidVASTEndCardManager ()

@property (nonatomic, strong) NSMutableArray<HyBidVASTEndCard *> *endCardsStorage;

@end

@implementation HyBidVASTEndCardManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.endCardsStorage = [NSMutableArray new];
    }
    return self;
}

- (void)addCompanion:(HyBidVASTCompanion *)companion
{
    if ([[companion staticResources] count] > 0) {
        for (HyBidVASTStaticResource *resource in [companion staticResources]) {
            if ([[resource content] length] > 0) {
                HyBidVASTEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_STATIC fromCompanion:companion withContent:[resource content]];
                [self.endCardsStorage addObject:endCard];
            }
        }
    }
    if ([[companion htmlResources] count] > 0) {
        for (HyBidVASTHTMLResource *resource in [companion htmlResources]) {
            if ([[resource content] length] > 0) {
                HyBidVASTEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_HTML fromCompanion:companion withContent:[resource content]];
                [self.endCardsStorage addObject:endCard];
            }
        }
    }
    if ([[companion iFrameResources] count] > 0) {
        for (HyBidVASTIFrameResource *resource in [companion iFrameResources]) {
            if ([[resource content] length] > 0) {
                HyBidVASTEndCard *endCard = [self createEndCardWithType:HyBidEndCardType_IFRAME fromCompanion:companion withContent:[resource content]];
                [self.endCardsStorage addObject:endCard];
            }
        }
    }
}

- (HyBidVASTEndCard *)createEndCardWithType:(HyBidVASTEndCardType)type fromCompanion:(HyBidVASTCompanion *)companion withContent:(NSString *)content
{
    HyBidVASTEndCard *endCard = [[HyBidVASTEndCard alloc] init];
    [endCard setType:type];
    [endCard setContent:content];
    [endCard setClickThrough:[[companion companionClickThrough] content]];
    
    NSMutableArray<NSString *> *trackings = [NSMutableArray new];
    for (HyBidVASTCompanionClickTracking *event in [companion companionClickTracking]) {
        [trackings addObject:[event content]];
    }
    [endCard setClickTrackings:trackings];
    
    [endCard setEvents:[companion trackingEvents]];
    
    return endCard;
}

- (NSArray<HyBidVASTEndCard *> *)endCards
{
    return self.endCardsStorage;
}

@end
