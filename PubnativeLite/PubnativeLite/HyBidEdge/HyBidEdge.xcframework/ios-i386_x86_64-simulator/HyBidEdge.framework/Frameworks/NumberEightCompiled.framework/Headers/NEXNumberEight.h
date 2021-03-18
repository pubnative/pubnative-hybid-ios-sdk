//
//  NEXNumberEight.h
//  NumberEightCompiled
//
//  Created by Oliver Kocsis on 14/06/2018.
//  Copyright © 2018 ai.numbereight. All rights reserved.
//

#import "NEXParameters.h"
#import "NEXAuthorizationChallenge.h"
#import "NEXEngine.h"
#import "NEXTypes.h"
#import "NEXSensor.h"

#import <UIKit/UIApplication.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NEXAPIToken;

NS_SWIFT_NAME(NumberEight)
@interface NEXNumberEight : NSObject

/**
 This method @b MUST @b be called by the adopter before the first usage of NumberEight SDK.
 We recommend that you call this from either:
    `application:willFinishLaunchingWithOptions:` or
    `application:DidFinishLaunchingWithOptions:`
 methods of the AppDelegate class.
 
 @param key A developer API key granted by NumberEight.

 @param launchOptions The launchOptions from AppDelegate's application:willFinishLaunchingWithOptions: method.

 @param challenge This block is called whenever any iOS sensor needs permissions from the user.
 By implementing this single callback the adopter can handle these challenges
 by calling the related resolver object's requestAuthorization method, which will automatically prompt the user for the related permissions.
 If nil, then a default implementation will be used on these challenges, which just calls the resolver's requestAuthorization method for all cases.

 @param consentOptions Allows the user to provide affirmative consent to the various
 processing activities of the SDK.
 If the user is consents to the processing activities and the ability to
 store and access data on their device, use `ConsentOptions.withConsentToAll()`.
 If using an IAB TCFv2 string, call `ConsentOptions.withConsentString()`.

 @param handler This block is called when NumberEight has finished initialising.
 If the first parameter is false, then an NSError will be provided. Otherwise, the initialisation was successful.
 */
+(NEXAPIToken * _Nonnull)startWithApiKey:(nullable NSString *)key
                           launchOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions
                          consentOptions:(NEXConsentOptions* _Nonnull)consentOptions
           facingAuthorizationChallenges:(nullable NEXAuthorizationChallenge)challenge
                              completion:(void(^_Nullable)(BOOL isSuccess, NSError * _Nullable error))handler;

/**
 @see NEXNumberEight#startWithLaunchOptions:facingAuthorizationChallenges:
 
 @param key: A developer API key granted by NumberEight.

 @param launchOptions: The launchOptions from AppDelegate's application:willFinishLaunchingWithOptions: method.

 @param consentOptions: Allows the user to provide affirmative consent to the various
 processing activities of the SDK.
 If the user is consents to the processing activities and the ability to
 store and access data on their device, use `NEXConsentOptions.withConsentToAll()`.
 If using an IAB TCFv2 string, call `NEXConsentOptions.withConsentString()`.

 @param handler This block is called when NumberEight has finished initialising.
 If the first parameter is false, then an NSError will be provided. Otherwise, the initialisation was successful.
 */
+(NEXAPIToken * _Nonnull)startWithApiKey:(nullable NSString *)key
                           launchOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions
                          consentOptions:(NEXConsentOptions* _Nonnull)consentOptions
                              completion:(void(^_Nullable)(BOOL isSuccess, NSError * _Nullable error))handler;

/**
 * Reload the SDK to recheck permissions, consent options, and re-register sensors.
 * This is particularly helpful when requesting consent from the user, giving a way
 * to start producing data with all available context.
 *
 * If the SDK has not yet been started, this call will have no effect.
 */
+(void)reload;

/**
 A device identifier for use in security and error reporting
*/
+(NSString* _Nonnull)deviceID;

/**
 * Provides granular control over the consent options for the NumberEight SDK, including
 * access to storage, location processing, and more.
 *
 * Use [NEXConsentOptions.withConsentString] to use IAB TCF Transparency-Consent strings.
 *
 * Consent options can be updated at any time. In which case, if NumberEight has
 * already been started, then it will reload.
 *
 * @returns This returns a copy of the current NEXConsentOptions object.  To update consent, call [NumberEight.setConsentOptions].
 */
+(NEXConsentOptions* _Nonnull)consentOptions;

/**
 Updates the consentOptions object, calls any listeners of the consent option.
 */
+(void)setConsentOptions:(NEXConsentOptions* _Nonnull) consentOptions;

/**
 * Add a callback to be notified whenever consent options are changed via [NumberEight setConsentOptions].
 *
 * @param listener: `OnConsentChangeListener` to report the new consent options.
 */
+(void)addOnConsentChangeListener:(id<OnConsentChangeListener>)listener
NS_SWIFT_NAME(add(onConsentChangeListener:));

/**
 * Remove a callback from notifications about consent changes.
 *
 * @param listener: `OnConsentChangeListener` to report the new consent options.
 */
+(void)removeOnConsentChangeListener:(id<OnConsentChangeListener>)listener
NS_SWIFT_NAME(remove(onConsentChangeListener:));


/**
 Subscribe to updates for the user's phyiscal activity.
 
 This might be a transition from stationary to walking, or a change of vehicle from
 bus to train.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.
 
 @param activityUpdated Called with an NEXGlimpse containing possibile values of NEXActivity.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToActivity:(void(^)(NEXGlimpse<NEXActivity *> * _Nonnull glimpse))activityUpdated
NS_SWIFT_NAME(activityUpdated(cb:));

/**
 Subscribe to updates for the user's phyiscal activity.

 This might be a transition from stationary to walking, or a change of vehicle from
 bus to train.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param activityUpdated Called with an NEXGlimpse containing possibile values of NEXActivity.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToActivity:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXActivity *> * _Nonnull glimpse))activityUpdated
NS_SWIFT_NAME(activityUpdated(parameters:cb:));

/**
 Unsubscribes from all `Activity` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromActivity;

/**
 Subscribe to updates of movement of the user's device.
 
 This will be called if the device starts or stops moving, or the confidence levels have
 changed.
 
 @param deviceMovementUpdated Called with an NEXGlimpse containing possibile values of NEXMovement.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToDeviceMovement:(void(^)(NEXGlimpse<NEXMovement *> * _Nonnull glimpse))deviceMovementUpdated
NS_SWIFT_NAME(deviceMovementUpdated(cb:));

/**
 Subscribe to updates of movement of the user's device.

 This will be called if the device starts or stops moving, or the confidence levels have
 changed.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param deviceMovementUpdated Called with an NEXGlimpse containing possibile values of NEXMovement.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToDeviceMovement:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXMovement *> * _Nonnull glimpse))deviceMovementUpdated
NS_SWIFT_NAME(deviceMovementUpdated(parameters:cb:));

/**
 Unsubscribes from all `DeviceMovement` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromDeviceMovement;

/**
 Subscribe to updates of changes to the position and orientation of the user's device.
 
 This could be when the user puts their phone in their pocket, or the device is rotated.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.
 
 @param devicePositionUpdated Called with an NEXGlimpse containing possibile values of NEXDevicePosition.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToDevicePosition:(void(^)(NEXGlimpse<NEXDevicePosition *> * _Nonnull glimpse))devicePositionUpdated
NS_SWIFT_NAME(devicePositionUpdated(cb:));

/**
 Subscribe to updates of changes to the position and orientation of the user's device.

 This could be when the user puts their phone in their pocket, or the device is rotated.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param devicePositionUpdated Called with an NEXGlimpse containing possibile values of NEXDevicePosition.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToDevicePosition:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXDevicePosition *> * _Nonnull glimpse))devicePositionUpdated
NS_SWIFT_NAME(devicePositionUpdated(parameters:cb:));

/**
 Unsubscribes from all `DevicePosition` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromDevicePosition;

/**
 Subscribe to updates of whether the user is indoors or outdoors.
 
 Along with indoors and outdoors, the user can also be enclosed, which signifies
 being outdoors, but under some canopy or basic structure like a bus shelter.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.
 
 @param indoorOutdoorUpdated Called with an NEXGlimpse containing possibile values of NEXIndoorOutdoor.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToIndoorOutdoor:(void(^)(NEXGlimpse<NEXIndoorOutdoor *> * _Nonnull glimpse))indoorOutdoorUpdated
NS_SWIFT_NAME(indoorOutdoorUpdated(cb:));

/**
 Subscribe to updates of whether the user is indoors or outdoors.

 Along with indoors and outdoors, the user can also be enclosed, which signifies
 being outdoors, but under some canopy or basic structure like a bus shelter.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param indoorOutdoorUpdated Called with an NEXGlimpse containing possibile values of NEXIndoorOutdoor.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToIndoorOutdoor:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXIndoorOutdoor *> * _Nonnull glimpse))indoorOutdoorUpdated
NS_SWIFT_NAME(indoorOutdoorUpdated(parameters:cb:));

/**
 Unsubscribes from all `IndoorOutdoor` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromIndoorOutdoor;

/**
 Subscribe to updates of the user's current location as an abstract type of place.
 
 This might be when the user walks into a bar, or enters a library.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.
 
 @param placeUpdated Called with an NEXGlimpse containing possibile values of NEXPlace.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToPlace:(void(^)(NEXGlimpse<NEXPlace *> * _Nonnull glimpse))placeUpdated
NS_SWIFT_NAME(placeUpdated(cb:));

/**
 Subscribe to updates of the user's current location as an abstract type of place.

 This might be when the user walks into a bar, or enters a library.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param placeUpdated Called with an NEXGlimpse containing possibile values of NEXPlace.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToPlace:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXPlace *> * _Nonnull glimpse))placeUpdated
NS_SWIFT_NAME(placeUpdated(parameters:cb:));

/**
 Unsubscribes from all `Place` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromPlace;

/**
 Subscribe to updates of the user's overall situation.
 
 This may be commuting, or working out for example. If available, a more granular
 situation will be given, such as having coffee.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.
 
 @param situationUpdated Called with an NEXGlimpse containing possibile values of NEXSituation.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToSituation:(void(^)(NEXGlimpse<NEXSituation *> * _Nonnull glimpse))situationUpdated
NS_SWIFT_NAME(situationUpdated(cb:));

/**
 Subscribe to updates of the user's overall situation.

 This may be commuting, or working out for example. If available, a more granular
 situation will be given, such as having coffee.
 It may also be because the confidence levels of the list of possibilities in the Glimpse
 has updated, but the most probable value is the same as before.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param situationUpdated Called with an NEXGlimpse containing possibile values of NEXSituation.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToSituation:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXSituation *> * _Nonnull glimpse))situationUpdated
NS_SWIFT_NAME(situationUpdated(parameters:cb:));

/**
 Unsubscribes from all `Situation` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromSituation;

/**
 Subscribe to updates of semantic time.
 
 This could be breakfast, lunch, or afternoon for example.
 
 @param timeUpdated Called with an NEXGlimpse containing possibile values of NEXTime.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToTime:(void(^)(NEXGlimpse<NEXTime *> * _Nonnull glimpse))timeUpdated
NS_SWIFT_NAME(timeUpdated(cb:));

/**
 Subscribe to updates of semantic time.

 This could be breakfast, lunch, or afternoon for example.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param timeUpdated Called with an NEXGlimpse containing possibile values of NEXTime.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToTime:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXTime *> * _Nonnull glimpse))timeUpdated
NS_SWIFT_NAME(timeUpdated(parameters:cb:));

/**
 Unsubscribes from all `Time` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromTime;

/**
 Subscribe to updates of the local weather.
 
 This could be hot and sunny, or cold and clear for example.
 
 @param weatherUpdated Called with an NEXGlimpse containing possibile values of NEXWeather.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToWeather:(void(^)(NEXGlimpse<NEXWeather *> * _Nonnull glimpse))weatherUpdated
NS_SWIFT_NAME(weatherUpdated(cb:));

/**
 Subscribe to updates of the local weather.

 This could be hot and sunny, or cold and clear for example.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param weatherUpdated Called with an NEXGlimpse containing possibile values of NEXWeather.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToWeather:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXWeather *> * _Nonnull glimpse))weatherUpdated
NS_SWIFT_NAME(weatherUpdated(parameters:cb:));

/**
 Unsubscribes from all `Weather` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromWeather;

/**
 Subscribe to updates of the device's lock status.
 
 This is either locked or unlocked.
 
 @param lockStatusUpdated Called with an NEXGlimpse containing possibile values of NEXLockStatus.
            @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToLockStatus:(void(^)(NEXGlimpse<NEXLockStatus *> * _Nonnull glimpse))lockStatusUpdated
NS_SWIFT_NAME(lockStatusUpdated(cb:));

/**
 Subscribe to updates of the device's lock status.

 This is either locked or unlocked.

 @param parameters An optional set of [Parameters] for the subscription, e.g. `Parameters.changesOnly`
 @param lockStatusUpdated Called with an NEXGlimpse containing possibile values of NEXLockStatus.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToLockStatus:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXLockStatus *> * _Nonnull glimpse))lockStatusUpdated
NS_SWIFT_NAME(lockStatusUpdated(parameters:cb:));

/**
 Unsubscribes from all `LockStatus` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromLockStatus;

/**
 Subscribe to updates of the user's cellular and WiFi reachability.
 
 This may be, for example, when a user connects to WiFi or a slow 2G connection.
 
 @param reachabilityUpdated Called with an NEXGlimpse containing possibile values of NEXReachability.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToReachability:(void(^)(NEXGlimpse<NEXReachability *> * _Nonnull glimpse))reachabilityUpdated
NS_SWIFT_NAME(reachabilityUpdated(cb:));

/**
 Subscribe to updates of the user's cellular and WiFi reachability.

 This may be, for example, when a user connects to WiFi or a slow 2G connection.
 
 @param parameters An optional set of `NEXParameters` for the subscription, e.g. `Parameters.changesOnly`
 @param reachabilityUpdated Called with an NEXGlimpse containing possibile values of NEXReachability.
 @b This @b will @b be @b called @b from @b a @b separate @b thread.
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)subscribeToReachability:(NEXParameters* _Nullable)parameters cb:(void(^)(NEXGlimpse<NEXReachability *> * _Nonnull glimpse))reachabilityUpdated
NS_SWIFT_NAME(reachabilityUpdated(parameters:cb:));

/**
 Unsubscribes from all `Reachability` subscriptions maintained by the receiver.
 
 @return A reference to the NEXNumberEight object to allow chaining.
 */
-(NEXNumberEight *)unsubscribeFromReachability;


/**
 Unsubscribes from all subscriptions maintained by the receiver.

 @return A reference to the NEXNumberEight object to allow chaining.
*/
-(NEXNumberEight *)unsubscribeFromAll;

@end

@interface NEXNumberEight(ManualSubscription)

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

  @return A reference to the NEXNumberEight object to allow chaining.
*/
-(NEXNumberEight *)subscribeToTopic:(const NSString* _Nonnull)topic
                         parameters:(nullable NEXParameters *) parameters
                            handler:(NEXGlimpseHandler<__kindof NEXSensorItem *> * _Nonnull)handler
NS_REFINED_FOR_SWIFT;

/**
  Requests a new `NEXGlimpse` from a publisher publishing to `topic`.

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
           parameters:(nullable NEXParameters *) parameters
              handler:(NEXGlimpseHandler<__kindof NEXSensorItem *> * _Nonnull)handler
NS_REFINED_FOR_SWIFT;

/**
  Unsubscribes from all subscriptions to this topic maintained by the receiver.

  @return A reference to the `NEXNumberEight` object to allow chaining.
*/
-(NEXNumberEight *)unsubscribeFrom:(const NSString* _Nonnull)topic;

@end

@interface NEXNumberEight(CreationForTesting)

-(instancetype)initWithEngine:(NEXEngine *)engine;

@end

NS_SWIFT_NAME(NE)
@interface NEXNE : NEXNumberEight
@end

NS_ASSUME_NONNULL_END
