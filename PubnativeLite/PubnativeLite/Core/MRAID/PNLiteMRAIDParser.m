//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNLiteMRAIDParser.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteMRAIDParser ()

- (BOOL)isValidCommand:(NSString *)command;
- (BOOL)checkParamsForCommand:(NSString *)command params:(NSDictionary *)params;

@end

@implementation PNLiteMRAIDParser

- (NSDictionary *)parseCommandUrl:(NSString *)commandUrl; {
    /*
     The command is a URL string that looks like this:
     
     mraid://command?param1=val1&param2=val2&...
     
     We need to parse out the command, create a dictionary of the paramters and their associated values,
     and then send an appropriate message back to the MRAIDView to run the command.
     */
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@ %@", NSStringFromSelector(_cmd), commandUrl]];
    
    // Remove mraid:// prefix.
    NSString *s = [commandUrl substringFromIndex:8];
    
    NSString *command;
    NSMutableDictionary *params;
    
    // Check for parameters, parse them if found
    NSRange range = [s rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        command = [s substringToIndex:range.location];
        NSString *paramStr = [s substringFromIndex:(range.location + 1)];
        NSArray *paramArray = [paramStr componentsSeparatedByString:@"&"];
        params = [NSMutableDictionary dictionaryWithCapacity:5];
        for (NSString *param in paramArray) {
            range = [param rangeOfString:@"="];
            NSString *key = [param substringToIndex:range.location];
            NSString *val = [param substringFromIndex:(range.location + 1)];
            [params setValue:val forKey:key];
        }
    } else {
        command = s;
    }
    
    // Check for valid command.
    if (![self isValidCommand:command]) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"command %@ is unknown", command]];
        return nil;
    }
    
    // Check for valid parameters for the given command.
    if (![self checkParamsForCommand:command params:params]) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"command URL %@ is missing parameters", commandUrl]];
        return nil;
    }
    
    NSObject *paramObj;
    if (
        [command isEqualToString:@"createCalendarEvent"] ||
        [command isEqualToString:@"expand"] ||
        [command isEqualToString:@"open"] ||
        [command isEqualToString:@"playVideo"] ||
        [command isEqualToString:@"sendSMS"] ||
        [command isEqualToString:@"callNumber"] ||
        [command isEqualToString:@"setOrientationProperties"] ||
        [command isEqualToString:@"setResizeProperties"] ||
        [command isEqualToString:@"storePicture"] ||
        [command isEqualToString:@"useCustomClose"]
        ) {
        if ([command isEqualToString:@"expand"] ||
                   [command isEqualToString:@"open"] ||
                   [command isEqualToString:@"playVideo"] ||
                   [command isEqualToString:@"sendSMS"] ||
                   [command isEqualToString:@"callNumber"] ||
                   [command isEqualToString:@"storePicture"]) {
            paramObj = [params valueForKey:@"url"];
        } else if ([command isEqualToString:@"setOrientationProperties"] ||
                   [command isEqualToString:@"setResizeProperties"]) {
            paramObj = params;
        } else if ([command isEqualToString:@"useCustomClose"]) {
            paramObj = [params valueForKey:@"useCustomClose"];
        }
        command = [command stringByAppendingString:@":"];
    }

    NSMutableDictionary *commandDict = [@{@"command" : command} mutableCopy];
    if (paramObj) {
        commandDict[@"paramObj"] = paramObj;
    }
    return commandDict;
}

- (BOOL)isValidCommand:(NSString *)command {
    NSArray *kCommands = @[
                           @"close",
                           @"expand",
                           @"open",
                           @"playVideo",
                           @"sendSMS",
                           @"callNumber",
                           @"resize",
                           @"setOrientationProperties",
                           @"setResizeProperties",
                           @"storePicture",
                           @"useCustomClose"
                           ];

    return [kCommands containsObject:command];
}

- (BOOL)checkParamsForCommand:(NSString *)command params:(NSDictionary *)params; {
    if ([command isEqualToString:@"open"] || [command isEqualToString:@"playVideo"] || [command isEqualToString:@"storePicture"] || [command isEqualToString:@"sendSMS"] || [command isEqualToString:@"callNumber"]) {
        return ([params valueForKey:@"url"] != nil);
    } else if ([command isEqualToString:@"setOrientationProperties"]) {
        return (
                [params valueForKey:@"allowOrientationChange"] != nil &&
                [params valueForKey:@"forceOrientation"] != nil
                );
    } else if ([command isEqualToString:@"setResizeProperties"]) {
        return (
                [params valueForKey:@"width"] != nil &&
                [params valueForKey:@"height"] != nil &&
                [params valueForKey:@"offsetX"] != nil &&
                [params valueForKey:@"offsetY"] != nil &&
                [params valueForKey:@"customClosePosition"] != nil &&
                [params valueForKey:@"allowOffscreen"] != nil
                );
    } else if ([command isEqualToString:@"useCustomClose"]) {
        return ([params valueForKey:@"useCustomClose"] != nil);
    }
    return YES;
}

@end
