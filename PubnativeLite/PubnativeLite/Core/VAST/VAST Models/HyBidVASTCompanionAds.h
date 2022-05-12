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
#import "HyBidVASTCompanion.h"
#import "HyBidXMLElementEx.h"

typedef enum {
    /**
         The video player must attempt to display the contents for all <Companion> elemens provided;
         if all Companion creative cannot be displayed, the Ad should be disregarded and the ad server should be notified using the <Error> element.
         */
    HyBidVASTCompanionAdRequirement_ALL,
    /**
         The video player must attempt to display content from at least one of the <Companion> elements provided
         (i.e. display the one with dimensions that best fit the page); if none of the Companion creative can be displayed, the Ad should be disregarded
         and the ad server should be notified using the <Error> element.
         */
    HyBidVASTCompanionAdRequirement_ANY,
    /**
         The video player may choose to not display any of the Companion creative, but is not restricted from doing so; The ad server may
         use this option when the advertiser prefers that the master ad be displayed with or without the Companion creative.
         */
    HyBidVASTCompanionAdRequirement_NONE
} HyBidVASTCompanionAdRequirement;

@interface HyBidVASTCompanionAds : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCompanionAdsXMLElement:(HyBidXMLElementEx *)companionAdsXMLElement;

- (HyBidVASTCompanionAdRequirement)required;

- (NSArray<HyBidVASTCompanion *> *)companions;

@end
