//
//  ATOMConsentStringParser.h
//  SPTProximityKit
//
//  Created by Quentin Beaudouin on 04/06/2020.
//  Copyright © 2020 Alexandre Fortoul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATOMTCFModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATOMTCStringParser : NSObject

+ (ATOMTCFModel *)parseConsentString:(NSString *)consentString
    NS_SWIFT_NAME(parse(consentString:));

@end

NS_ASSUME_NONNULL_END
