//
//  VrvResponseModel.m
//  HyBid
//
//  Created by Eros Garcia Ponte on 23.03.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "VrvResponseModel.h"

@implementation VrvResponseModel

- (void)dealloc {
    self.dictionary = nil;
    self.status = nil;
    self.errorMessage = nil;
    self.ads = nil;
}

- (instancetype)initWithXml:(NSDictionary *)dictionary {
    if (self) {
        self.status = dictionary[@"status"];
        self.errorMessage = dictionary[@"error_message"];
    }
    return self;
}

@end
