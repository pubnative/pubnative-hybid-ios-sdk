//
//  OnConsentChangedListener.h
//  NumberEightCompiled
//
//  Created by Matthew Paletta on 2020-10-13.
//  Copyright © 2020 ai.numbereight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NEXConsentOptions;

@protocol OnConsentChangeListener

/**
 Delegate callback executed when `NumberEight.consentOptions` is changed.  The listener should check that it still has the necessary consent required to run.
 */
-(void)consentDidChange: (NEXConsentOptions*)consentOptions;

@end
