//
//  Quote.h
//  HyBidDemo
//
//  Created by Fares Ben Hamouda on 04.08.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quote : NSObject

@property (nonatomic, strong) NSString* quoteText;
@property (nonatomic, strong) NSString* quoteAuthor;

- (id) initWithText:(NSString*)text andAuthor:(NSString*)author;

@end
