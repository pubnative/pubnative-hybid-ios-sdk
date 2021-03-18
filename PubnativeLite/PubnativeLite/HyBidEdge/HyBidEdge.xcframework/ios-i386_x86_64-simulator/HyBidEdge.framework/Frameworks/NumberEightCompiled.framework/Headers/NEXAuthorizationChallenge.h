
//  NEXAuthorizationChallengeResolver.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 05/11/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NEXAuthorizationSource) {
    kNEXAuthorizationSourceLocation = 0,
};

NS_ASSUME_NONNULL_BEGIN

@protocol NEXAuthorizationChallengeResolver <NSObject>

@required

-(void)requestAuthorization;

@end

typedef void (^NEXAuthorizationChallenge)(NEXAuthorizationSource, id<NEXAuthorizationChallengeResolver>);


NS_ASSUME_NONNULL_END
