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

#import "HyBidVASTLinear.h"
#import "HyBidVASTXMLParserHelper.h"
#import "HyBidVASTTrackingEvents.h"

@interface HyBidVASTLinear ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@property (nonatomic) int index;

@property (nonatomic, strong)HyBidVASTXMLParserHelper *parserHelper;

@end

@implementation HyBidVASTLinear

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

- (NSString *)duration
{
    NSString *query = @"//Creatives/Creative/Linear/Duration";
    return [self.parserHelper getContentForQuery: query];
}

- (HyBidVASTAdParameters *)adParameters
{
    return [[HyBidVASTAdParameters alloc] initWithDocumentArray:self.vastDocumentArray atIndex:self.index];
}

- (HyBidVASTIcons *)icons
{
    return [[HyBidVASTIcons alloc] initWithDocumentArray:self.vastDocumentArray];
}

- (HyBidVASTMediaFiles *)mediaFiles
{
    return [[HyBidVASTMediaFiles alloc] initWithDocumentArray:self.vastDocumentArray];
}

- (NSString *)skipOffset
{
    NSArray *linears = [self.parserHelper getArrayResultsForQuery:@"//Creatives/Creative/Linear"];
    
    NSString *skipOffset = [self.parserHelper getContentForAttribute:@"skipoffset" inNode: linears[self.index]];
    return skipOffset == nil ? @"-1" : skipOffset;
}

- (NSArray<HyBidVASTTrackingEvent *> *)trackingEvents
{
    NSArray<HyBidVASTTrackingEvent *> *trackingEvents = [[[HyBidVASTTrackingEvents alloc] initWithDocumentArray: self.vastDocumentArray] trackingEvents];
    return trackingEvents;
}

- (HyBidVASTVideoClicks *)videoClicks
{
    return [[HyBidVASTVideoClicks alloc] initWithDocumentArray:self.vastDocumentArray];
}

@end
