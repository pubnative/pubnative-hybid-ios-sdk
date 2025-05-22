// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

BOOL validateXMLDocSyntax(NSData *document);                         // check for valid XML syntax using xmlReadMemory
BOOL validateXMLDocAgainstSchema(NSData *document, NSData *schema);  // check for valid VAST 2.0 syntax using xmlSchemaValidateDoc & vast_2.0.1.xsd schema
NSArray *performXMLXPathQuery(NSData *document, NSString *query);    // parse the document for the xpath in 'query' using xmlXPathEvalExpression
