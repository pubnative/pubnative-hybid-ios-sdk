//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import "VWAdLibrary.h"
#import "HyBidSettings.h"

@implementation VWAdLibrary

static VWAdLibrary *instance = nil;

+ (nonnull NSString *)sdkVersion
{
    return [HyBidSettings sharedInstance].sdkVersion;
}

+ (VWAdLibrary *)shared
{
    @synchronized(instance) {
        if (instance == nil) {
            instance = [[VWAdLibrary alloc] init];
        }
    }
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - U.S. Privacy String

- (void)setIABUSPrivacyString:(NSString *)privacyString
{
    [[NSUserDefaults standardUserDefaults] setObject:privacyString forKey:kUSPrivacyKey];
}

- (NSString *)getIABUSPrivacyString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUSPrivacyKey];
}

- (void)removeIABUSPrivacyString
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSPrivacyKey];
}

- (NSString *)getFormattedAndPercentEncodedIABUSPrivacyString
{
    return [[self getFormattedIABUSPrivacyString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];;
}

- (NSString *)getFormattedIABUSPrivacyString
{
    NSString *privacyString = [self getIABUSPrivacyString];
    privacyString = [privacyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([privacyString isEqualToString:@"null"]) {
        privacyString = @"";
    }
    
    return privacyString;
}

- (BOOL)usPrivacyOptOut
{
    NSString *privacyString = [self getFormattedIABUSPrivacyString];
    
    if ([privacyString length] >= 3) {
        NSString *thirdComponent = [privacyString substringWithRange:NSMakeRange(2, 1)];
        if ([[thirdComponent uppercaseString] isEqualToString:@"Y"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        // There is no valid privacy string set, assuming there is no opt out
        return  NO;
    }
}

@end
