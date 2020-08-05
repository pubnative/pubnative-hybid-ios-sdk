//
//  Quote.m
//  HyBidDemo
//
//  Created by Fares Ben Hamouda on 04.08.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "Quote.h"

@implementation Quote

- (id) initWithText:(NSString*)text andAuthor:(NSString*)author {
    self = [super init];
    if (self) {
        self.quoteAuthor = author;
        self.quoteText = text;
    }
    return self;
}

@end
