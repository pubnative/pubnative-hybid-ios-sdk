//
//  NEXParameters.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 21/05/2020.
//  Copyright © 2020 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Parameters)
@interface NEXParameters : NSObject

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString *filter;

/**
 No additional filtering: glimpses are received as fast as possible.
 */
@property (class, readonly) NEXParameters *sensitivityRealTime;

/**
 Mild filtering to decrease the sensitivity of context detection.

 Most useful for adapting UI behaviour based on context.
 */
@property (class, readonly) NEXParameters *sensitivitySmooth;

/**
 Moderate filtering to ignore brief changes in context.

 Most useful for reporting observed behaviours while the app is running.
 */
@property (class, readonly) NEXParameters *sensitivitySmoother;

/**
 Stronger filtering to detect only longer-term contextual changes
 over 5 minutes in length.

 Most useful for reporting observed behaviours in apps that run continuously
 in the background.
 */
@property (class, readonly) NEXParameters *sensitivityLongTerm;

/**
 Only glimpses with changed values, or different possibility orders, will be received.
 */
@property (class, readonly) NEXParameters *changesOnly;

/**
 Only glimpses with a changed most probably value will be received.
 */
@property (class, readonly) NEXParameters *changesMostProbableOnly;

/**
 Only glimpses with a significant change in confidence will be received.
 */
@property (class, readonly) NEXParameters *significantChange;

/**
 Create a custom set of NEXParameters with a filter string.
 */
-(instancetype)initWithFilter:(NSString *)filter NS_DESIGNATED_INITIALIZER;

+(instancetype)parametersWithFilter:(NSString *)filter
NS_SWIFT_NAME(withFilter(filter:));

/**
 Combine two sets of NEXParameters together to create a combined set of NEXParameters.

 The NEXParameters on the left hand side will take
 precedence over the right hand side.
 */
-(instancetype)and:(NEXParameters *)other;


@end

NS_ASSUME_NONNULL_END
