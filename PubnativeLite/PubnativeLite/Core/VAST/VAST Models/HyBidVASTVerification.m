// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
