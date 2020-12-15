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

#import "PNLiteOrientationManager.h"

@interface PNLiteOrientationManager ()

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation PNLiteOrientationManager


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.orientation = UIInterfaceOrientationUnknown;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static PNLiteOrientationManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PNLiteOrientationManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)load {
    [[PNLiteOrientationManager sharedInstance] startListening];
}

+ (UIInterfaceOrientation)orientation {
    if([PNLiteOrientationManager sharedInstance].orientation == UIInterfaceOrientationUnknown) {
        [PNLiteOrientationManager sharedInstance].orientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return [PNLiteOrientationManager sharedInstance].orientation;
}

- (void)startListening {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}


- (void)didChangeStatusBarOrientation:(NSNotification *)notification {
    if ([PNLiteOrientationManager sharedInstance].orientation != [UIApplication sharedApplication].statusBarOrientation) {
        [PNLiteOrientationManager sharedInstance].orientation = [UIApplication sharedApplication].statusBarOrientation;
        [self sendDidChangeOrientationNotication];
    }
}

- (void)sendDidChangeOrientationNotication {
    [self.delegate orientationManagerDidChangeOrientation];
}

@end
