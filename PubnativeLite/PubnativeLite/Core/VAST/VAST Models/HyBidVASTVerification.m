//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidVASTVerification.h"
#import "HyBidVASTVerificationParameters.h"

@interface HyBidVASTVerification ()

@property (nonatomic, strong)HyBidXMLElementEx *verificationXmlElement;

@end

@implementation HyBidVASTVerification

- (instancetype)initWithVerificationXMLElement:(HyBidXMLElementEx *)verificationXMLElement
{
    if (verificationXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.verificationXmlElement = verificationXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)vendor
{
    return [self.verificationXmlElement attribute:@"vendor"];
}

// MARK: - Elements

- (NSArray<HyBidVASTExecutableResource *> *)executableResource
{
    NSString *query = @"/ExecutableResource";
    NSArray<HyBidXMLElementEx *> *result = [self.verificationXmlElement query:query];
    NSMutableArray<HyBidVASTExecutableResource *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTExecutableResource *executableResource = [[HyBidVASTExecutableResource alloc] initWithExecutableResourceXMLElement:result[i]];
        [array addObject:executableResource];
    }
    
    return array;
}

- (NSArray<HyBidVASTJavaScriptResource *> *)javaScriptResource
{
    NSString *query = @"/JavaScriptResource";
    NSArray<HyBidXMLElementEx *> *result = [self.verificationXmlElement query:query];
    NSMutableArray<HyBidVASTJavaScriptResource *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTJavaScriptResource *javaScriptResource = [[HyBidVASTJavaScriptResource alloc] initWithJavaScriptResourceXMLElement:result[i]];
        [array addObject:javaScriptResource];
    }
    
    return array;
}

- (HyBidVASTTrackingEvents *)trackingEvents
{
    if ([[self.verificationXmlElement query:@"/TrackingEvents"] count] > 0) {
        HyBidXMLElementEx *trackingEventsElement = [[self.verificationXmlElement query:@"/TrackingEvents"] firstObject];
        HyBidVASTTrackingEvents *trackingEvents = [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:trackingEventsElement];
        return trackingEvents;
    }
    return nil;
}


- (HyBidVASTVerificationParameters *)verificationParameters {
    if ([[self.verificationXmlElement query:@"/VerificationParameters"] count] > 0) {
        HyBidXMLElementEx *verificationParametersElement = [[self.verificationXmlElement query:@"/VerificationParameters"] firstObject];
        HyBidVASTVerificationParameters *verificationParameters = [[HyBidVASTVerificationParameters alloc] initWithVerificationParametersXMLElement:verificationParametersElement];
        return verificationParameters;
    }
    return nil;
}

@end
