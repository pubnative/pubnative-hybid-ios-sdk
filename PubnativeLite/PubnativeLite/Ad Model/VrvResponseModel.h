//
//  VrvResponseModel.h
//  HyBid
//
//  Created by Eros Garcia Ponte on 23.03.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VrvResponseModel : NSObject

@property (nonatomic, strong) NSDictionary *dictionary;

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSArray *ads;

- (instancetype)initWithXml:(NSDictionary *)dictionary;

@end
