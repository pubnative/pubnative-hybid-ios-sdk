//
//  VrvAdRequestModel.m
//  HyBid
//
//  Created by Eros Garcia Ponte on 23.03.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "VrvAdRequestModel.h"

@implementation VrvAdRequestModel

- (void)dealloc {
    self.requestParameters = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestParameters = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
