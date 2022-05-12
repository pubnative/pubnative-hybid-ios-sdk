//
//  Copyright © 2022 PubNative. All rights reserved.
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
