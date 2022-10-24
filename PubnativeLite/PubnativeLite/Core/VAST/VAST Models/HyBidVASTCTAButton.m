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

#import "HyBidVASTCTAButton.h"

@interface HyBidVASTCTAButton ()

@property (nonatomic, strong)HyBidXMLElementEx *ctaButtonXMLElement;

@end

@implementation HyBidVASTCTAButton

- (instancetype)initWithCTAButtonXMLElement:(HyBidXMLElementEx *)ctaButtonXMLElement
{
    if (ctaButtonXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.ctaButtonXMLElement = ctaButtonXMLElement;
    }
    return self;
}

// MARK: - Elements

- (NSString *)htmlData
{
    NSString *query = @"/HtmlData";
    if ([[self.ctaButtonXMLElement query:query] count] > 0) {
        HyBidXMLElementEx* element = [[self.ctaButtonXMLElement query:query] firstObject];
        return [element value];
    }
    return nil;
}

- (HyBidVASTTrackingEvents *)trackingEvents
{
    if ([[self.ctaButtonXMLElement query:@"/TrackingEvents"] count] > 0) {
        HyBidXMLElementEx *trackingEventsElement = [[self.ctaButtonXMLElement query:@"/TrackingEvents"] firstObject];
        return [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:trackingEventsElement];
    }
    return nil;
}

@end
