////
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidAdSourceConfig.h"
#import "AdSourceConfigParameter.h"

@implementation HyBidAdSourceConfig

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.eCPM = [dictionary[AdSourceConfigParameter.eCPM] doubleValue];
        self.enabled = [dictionary[AdSourceConfigParameter.enabled] boolValue];
        
        if ([[dictionary objectForKey:AdSourceConfigParameter.name] respondsToSelector:@selector(stringValue)]) {
            self.name = [dictionary[AdSourceConfigParameter.name] stringValue];
        }
        else {
            self.name = dictionary[AdSourceConfigParameter.name];
        }
        
        if ([[dictionary objectForKey:AdSourceConfigParameter.vastTagUrl] respondsToSelector:@selector(stringValue)]) {
            self.vastTagUrl = [dictionary[AdSourceConfigParameter.vastTagUrl] stringValue];
        }
        else {
            self.vastTagUrl = dictionary[AdSourceConfigParameter.vastTagUrl];
        }
        
        if ([[dictionary objectForKey:AdSourceConfigParameter.type] respondsToSelector:@selector(stringValue)]) {
            self.type = [dictionary[AdSourceConfigParameter.type] stringValue];
        }
        else {
            self.type = dictionary[AdSourceConfigParameter.type];
        }
    }
    return self;
}

@end
