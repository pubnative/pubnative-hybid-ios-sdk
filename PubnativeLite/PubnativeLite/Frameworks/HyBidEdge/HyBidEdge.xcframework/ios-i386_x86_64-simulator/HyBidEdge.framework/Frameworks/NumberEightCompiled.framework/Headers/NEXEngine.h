//
//  NEXEngine.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 12/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXSubscription.h"
#import "NEXParameters.h"
#import "NEXTypes.h"
#import "NEXTypes_private.h"
#import "NEXAuthorizationChallenge.h"
#import "NEXGlimpseHandler.h"
#import "NEXConsentOptions.h"
#import "OnConsentChangedListener.h"
#import "NEXSensor.h"

#import <UIKit/UIApplication.h>
#import <CoreLocation/CLLocationManager.h>
#import <Foundation/Foundation.h>

@class NEXNumberEight;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Token to be used for using other NumberEight Add-ons eg. InsightsSDK
NS_SWIFT_NAME(APIToken)
@interface NEXAPIToken : NSObject

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly, nullable) NSDictionary<UIApplicationLaunchOptionsKey, id> *launchOptions;
@property (nonatomic, readonly) NEXConsentOptions* consentOptions;

@end

#pragma mark - Engine Creation

NS_SWIFT_NAME(Engine)
@interface NEXEngine : NSObject 

@property (nonatomic, readonly) NEXConsentOptions *consentOptions;
@property (nonatomic, class, readonly) NEXEngine *sharedInstance;

-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

/**
 @see NEXEngine#startWithLaunchOptions:facingAuthorizationChallenges:
 
 @param key: A developer API key granted by NumberEight.

 @param launchOptions: The launchOptions from AppDelegate's application:willFinishLaunchingWithOptions: method.

 @param consentOptions: Allows the user to provide affirmative consent to the various
 processing activities of the SDK.
 If the user is consents to the processing activities and the ability to
 store and access data on their device, use `NEXConsentOptions.withConsentToAll()`.
 If using an IAB TCFv2 string, call `NEXConsentOptions.withConsentString()`.

 @param handler This block is called when NEXEngine has finished initialising.
 If the first parameter is false, then an NSError will be provided. Otherwise, the initialisation was successful.
 */
-(NEXAPIToken * _Nonnull)startWithApiKey:(nullable NSString *)key
                           launchOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions
                          consentOptions:(NEXConsentOptions* _Nonnull)consentOptions
           facingAuthorizationChallenges:(NEXAuthorizationChallenge)challenge
                                   queue:(nullable dispatch_queue_t)queue
                              completion:(void(^_Nullable)(BOOL isSuccess, NSError * _Nullable error))handler;

/**
 * Reload the SDK to recheck permissions, consent options, and re-register sensors.
 * This is particularly helpful when requesting consent from the user, giving a way
 * to start producing data with all available context.
 *
 * If the SDK has not yet been started, this call will have no effect.
 */
-(void)reload;

/**
 * Reload the SDK to recheck permissions, consent options, and re-register sensors.
 * This is particularly helpful when requesting consent from the user, giving a way
 * to start producing data with all available context.
 *
 * If the SDK has not yet been started, this call will have no effect.
 */
+(void)reload;

/**
  Stops the NumberEight engine.
*/
-(void)stopEngine;

/**
  Stops the NumberEight engine.
*/
+(void)stopEngine;

/**
 Updates the consentOptions object, calls any listeners of the consent option.
 */
-(void)updateConsentOptions:(NEXConsentOptions* _Nonnull) consentOptions;

/**
 * Add a callback to be notified whenever consent options are changed via [NumberEight setConsentOptions].
 *
 * @param listener: `OnConsentChangeListener` to report the new consent options.
 */
-(void)addOnConsentChangeListener:(id<OnConsentChangeListener> _Nullable) listener;

/**
 * Remove a callback from notifications about consent changes.
 *
 * @param listener: `OnConsentChangeListener` to report the new consent options.
 */
-(void)removeOnConsentChangeListener:(id<OnConsentChangeListener>) listener;
@end

#pragma mark - Convenience Interface

@interface NEXEngine (Subscriptions)

/**
  @param topic The topic to query.
  @return true is is a publisher exists under `topic`, otherwise false.
*/
-(bool)publisherExistsFor:(NSString*)topic
NS_SWIFT_NAME(publisherExistsFor(topic:));

@end

#pragma mark - Manual Subscription Interface

@interface NEXEngine (ManualSubscription)

/**
  Subscribes a `handler` to every non-null `NEXGlimpse` published under `topic`.

  @param topic The topic to subscribe to, e.g. "motion/accelerometer".
  A specific sensor can be subscribed to by subscribing to its `path`,
  for example: "motion/accelerometer/0".
  Subscriptions can also be more generic, such as subscribing to all motion
  events with "motion".
  The topics are defined as constants, that start with `kNETopicXxxx`.
  @param parameters An optional set of `NEXParameters` for the subscription, e.g. `Parameters.changesOnly`
  @param handler This block is called on each new Glimpse. 
  @b This @b will @b be @b called @b from @b a @b separate @b thread.

  @return A `NEXSubscription` handle.
  * This must be retained in a variable, otherwise the subscription will be
  destroyed immediately. The subscription will be closed when the handle goes
  out of scope, or when `NEXSubscription.cancel` is called.
*/
-(NEXSubscription *)subscribeToTopic:(const NSString* _Nonnull)topic
                          parameters:(nullable NEXParameters *)parameters
                             handler:(NEXGlimpseHandler<__kindof NEXSensorItem *> *)handler
__attribute__((warn_unused_result))
NS_REFINED_FOR_SWIFT;

/**
  Requests a new `Glimpse` from a publisher publishing to `topic`.

  The `handler` will be called at most once. If no publishers are able to
  honour the request, the handler will not be called.
  If multiple publishers honour the request, only the first to publish will
  call the handler.

  @see `subscribeToTopic`
  @param topic The topic to query.
  @param parameters An optional set of `NEXParameters` for the subscription, e.g. `Parameters.changesOnly`
  @param handler This block is called when request is complete.
  `handler` is guaranteed to be called either once or not at all.
  @b This @b will @b be @b called @b from @b a @b separate @b thread.

  @return `false` if no requestable publishers are found.
*/
-(BOOL)requestForTopic:(const NSString* _Nonnull)topic
           parameters:(nullable NEXParameters *)parameters
              handler:(NEXGlimpseHandler<__kindof NEXSensorItem *> *)handler
NS_REFINED_FOR_SWIFT;

@end

@protocol NEXLogSinkDelegate <NSObject>
@optional
-(void)onMessageLevel:(int)level tag:(NSString *)tag message:(NSString *)message;

@end

@interface NEXEngine(forInternalUsage) <Consentable>

@property (nonatomic, weak) id<NEXLogSinkDelegate> logSinkDelegate;

@end

@interface NSBundle (NEiOSSDK)

@property (class, nonatomic, readonly, nullable) NSBundle *nex_sdkBundle;

@end

NS_ASSUME_NONNULL_END
