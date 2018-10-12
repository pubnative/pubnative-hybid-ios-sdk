//
//  MPError.m
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import "MPError.h"

NSString * const kMOPUBErrorDomain = @"com.mopub.iossdk";

@implementation MOPUBError

+ (MOPUBError *)errorWithCode:(MOPUBErrorCode)code {
    return [MOPUBError errorWithCode:code localizedDescription:nil];
}

+ (MOPUBError *)errorWithCode:(MOPUBErrorCode)code localizedDescription:(NSString *)description {
    NSDictionary * userInfo = nil;
    if (description != nil) {
        userInfo = @{ NSLocalizedDescriptionKey: description };
    }

    return [self errorWithDomain:kMOPUBErrorDomain code:code userInfo:userInfo];
}

@end
