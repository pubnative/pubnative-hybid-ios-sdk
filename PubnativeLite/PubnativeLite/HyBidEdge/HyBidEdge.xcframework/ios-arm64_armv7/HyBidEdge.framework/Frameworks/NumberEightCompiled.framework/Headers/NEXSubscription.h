//
//  NEXSubscription.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 13/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A Subscription is a cancellable handle to a subscription block.
 If cancel() is called, or the object is deallocated, the subscription will be cancelled.
 **/
NS_SWIFT_NAME(Subscription)
@interface NEXSubscription : NSObject

@property (nonatomic, copy, readonly) NSString *topic;
@property (nonatomic, copy, readonly) NSUUID *UUID;

-(void)cancel;

@end
NS_ASSUME_NONNULL_END
