//
//  BugsnagSessionTrackingPayload.h
//  Bugsnag
//
//  Created by Jamie Lynch on 27/11/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PNLiteSession.h"

@interface BugsnagSessionTrackingPayload : NSObject

- (instancetype)initWithSessions:(NSArray<PNLiteSession *> *)sessions;

- (NSDictionary *)toJson;

@property NSArray<PNLiteSession *> *sessions;

@end
