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

#import "HyBidVASTVideoClicks.h"

@interface HyBidVASTVideoClicks ()

@property (nonatomic, strong)HyBidXMLElementEx *videoClicksXMLElement;

@end

@implementation HyBidVASTVideoClicks

- (instancetype)initWithVideoClicksXMLElement:(HyBidXMLElementEx *)videoClicksXMLElement;
{
    if (videoClicksXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.videoClicksXMLElement = videoClicksXMLElement;
    }
    return self;
}

- (NSArray<HyBidVASTClickTracking *> *)clickTrackings
{
    NSString *query = @"/ClickTracking";
    NSArray<HyBidXMLElementEx *> *result = [self.videoClicksXMLElement query:query];
    NSMutableArray<HyBidVASTClickTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTClickTracking *clickTracking = [[HyBidVASTClickTracking alloc] initWithClickTrackingXMLElement:result[i]];
        [array addObject:clickTracking];
    }
    
    return array;
}

- (HyBidVASTClickThrough *)clickThrough
{
    if ([[self.videoClicksXMLElement query:@"/ClickThrough"] count] > 0) {
        HyBidXMLElementEx *clickThroughElement = [[self.videoClicksXMLElement query:@"/ClickThrough"] firstObject];
        
        return [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:clickThroughElement];
    }
    return nil;
}

- (NSArray<HyBidVASTCustomClick *> *)customClicks
{
    NSString *query = @"/CustomClick";
    NSArray<HyBidXMLElementEx *> *result = [self.videoClicksXMLElement query:query];
    NSMutableArray<HyBidVASTCustomClick *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTCustomClick *customClick = [[HyBidVASTCustomClick alloc] initWithCustomClickXMLElement:result[i]];
        [array addObject:customClick];
    }
    
    return array;
}


@end
