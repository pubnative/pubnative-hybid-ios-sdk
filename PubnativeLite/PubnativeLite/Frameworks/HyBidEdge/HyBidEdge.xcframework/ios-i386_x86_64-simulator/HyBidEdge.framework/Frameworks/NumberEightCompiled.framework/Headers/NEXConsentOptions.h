//
//  NEXConsentOptions.h
//  NumberEightCompiled
//
//  Created by Matthew Paletta on 2020-10-13.
//  Copyright © 2020 ai.numbereight. All rights reserved.
//

#pragma once
#include "OnConsentChangedListener.h"
#include "Consentable.h"

#include "ConsentOptionsProperty.h"
#include <Foundation/Foundation.h>

NS_SWIFT_NAME(ConsentOptions)
@interface NEXConsentOptions : NSObject

+(instancetype _Nonnull)withDefault;

+(instancetype _Nonnull)withConsentToAll;

/**
 NumberEight Vendor ID Constant.
 */
+(int)VENDOR_ID NS_SWIFT_NAME(VENDOR_ID());

/**
  Create a NEXConsentOptions object with an IAB CMP Transparency-Consent string from a registered CMP.

  @param string: An IAB TCFv2 consent string.
 
  @throws ConsentException: if consentString could not be parsed.
  @throws IllegalArgumentException: if consentString is not encoded with Base64.
*/
+(instancetype _Nonnull)withConsentString:(NSString* _Nonnull)string NS_SWIFT_NAME(with(consentString:));

/**
 * Produces a string that represents the state of the consent options.
 * If a consent string was used in the creation of this object, it will be included in the
 * serialized form.
 */
-(NSString* _Nonnull)serialize;

-(bool)isEqual:(NEXConsentOptions* _Nullable)other;
-(NSUInteger)hash;

/**
 Checks if the NEXConsentOptions object has the required consent of the `Consentable` passed in.  Return true if all requirements of `Consentable` are enabled.  This will be re-checked when NumberEight.consentOptions is updated and the sensor will be stopped/started appropriately.
 */
-(bool)hasRequiredConsent:(id<Consentable> _Nullable) listener;

-(void)setConsent:(ConsentOptionsProperty) option to:(bool)to;
-(bool)hasConsent:(ConsentOptionsProperty) option;
@end
