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

#import "HyBidVASTTrackingEvents.h"

@interface HyBidVASTTrackingEvents ()

@property (nonatomic, strong)HyBidXMLElementEx *trackingEventsXMLElement;

@end

@implementation HyBidVASTTrackingEvents

- (instancetype)initWithTrackingEventsXMLElement:(HyBidXMLElementEx *)trackingEventsXMLElement
{
    if (trackingEventsXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.trackingEventsXMLElement = trackingEventsXMLElement;
    }
    return self;
}

- (NSArray<HyBidVASTTracking *> *)events
{
    NSString *query = @"/Tracking";
    NSArray<HyBidXMLElementEx *> *result = [self.trackingEventsXMLElement query:query];
    NSMutableArray<HyBidVASTTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTTracking *event = [[HyBidVASTTracking alloc] initWithTrackingXMLElement:result[i]];
        [array addObject:event];
    }
    
    return array;
}

@end
