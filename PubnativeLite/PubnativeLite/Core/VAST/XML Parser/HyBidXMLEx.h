// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXML.h"
#import "HyBidXMLElementEx.h"

@interface HyBidXMLEx : NSObject {
	HyBidXML *hyBidXML;
	HyBidXMLElementEx *rootElement;
}

// Creates an autoreleased parser
+(HyBidXMLEx *) parserWithXML:(NSString *) xml;

-(BOOL) invalidXML;
-(NSString *) parsingErrorDescription;
-(HyBidXMLElementEx *) rootElement;

@end

