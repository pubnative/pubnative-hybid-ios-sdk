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

#import "PNLiteUserConsentRequestModel.h"

@interface PNLiteUserConsentRequestModel()

@property (nonatomic, strong) NSString *deviceIDType;
@property (nonatomic, assign) BOOL consent;

@end

@implementation PNLiteUserConsentRequestModel

- (void)dealloc {
    self.deviceID = nil;
    self.deviceIDType = nil;
}

- (instancetype)initWithDeviceID:(NSString *)deviceID
                withDeviceIDType:(NSString *)deviceIDType
                     withConsent:(BOOL)consent {
    self = [super init];
    if (self) {
        self.deviceID = deviceID;
        self.deviceIDType = deviceIDType;
        self.consent = consent;
    }
    return self;
}

- (NSData *)createPOSTBody {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    if (self.deviceID) {
        [dictionary setObject:self.deviceID forKey:@"did"];
    }
    if (self.deviceIDType) {
        [dictionary setObject:self.deviceIDType forKey:@"did_type"];
    }
    
    if ([NSNumber numberWithBool:self.consent] != nil ) {
        [dictionary setObject:[NSNumber numberWithBool:self.consent] forKey:@"consent"];
    }
    
    NSError * error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return jsonData;
}
@end
