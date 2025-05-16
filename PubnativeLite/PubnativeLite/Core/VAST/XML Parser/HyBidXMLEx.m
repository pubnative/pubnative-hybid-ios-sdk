// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidXMLEx.h"

@interface HyBidXMLEx ()
-(void) setHyBidXML:(HyBidXML *) value;
@end

@implementation HyBidXMLEx

+(HyBidXMLEx *) parserWithXML:(NSString *) xml {
	HyBidXMLEx *ex = [[HyBidXMLEx alloc] init];
	[ex setHyBidXML:[[HyBidXML alloc] initWithXMLString:xml]];
	return ex;
}

-(void) setHyBidXML:(HyBidXML *) value {
	hyBidXML = value;
}

-(BOOL) invalidXML {
	return hyBidXML.invalidXML;
}

-(NSString *) parsingErrorDescription {
	return hyBidXML.parsingErrorDescription;
}

-(HyBidXMLElementEx *) rootElement {
	if (!rootElement) {
		rootElement = [[HyBidXMLElementEx alloc] initWithElement:hyBidXML.rootXMLElement];
	}

	return rootElement;
}

@end
