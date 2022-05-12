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

#import <Foundation/Foundation.h>
#import "HyBidXML.h"

@interface HyBidXMLElementEx : NSObject {
	HyBidXMLElement *element;
	BOOL firstPass;
	NSMutableDictionary *attributes;
}

// A dictionary with all attributes of a given element
@property (nonatomic, readonly) NSDictionary *attributes;

-(id) initWithElement:(HyBidXMLElement *) value;

// Looks for a child element. Returns an autoreleased object
// if the element exists, of nil otherwise
-(HyBidXMLElementEx *) child:(NSString *) elementName;

// Advances to the next element with the same name of this instance's name
-(BOOL) next;

// Returns the value of a specific attribute, or nil otherwise
-(NSString *) attribute:(NSString *) name;

// Returns the value of a specific attribute as an int value, or 0 otherwise
-(int) intAttribute:(NSString *) name;

// Returns ths value of a specific attribute as an long value, or 0 otherwise
-(long long) longAttribute:(NSString *) name;

// Returns the text of this tag, if any
-(NSString *) value;

// Return the text of this tag as an int
-(int) intValue;

/*

*/
-(NSArray *) query:(NSString *) search;

// Retunrs the text of this tas as a long
-(long long) longValue;

// Returns the text of this tag
-(NSString *) text;

// Returns the name of this tag
-(NSString *) name;

@end
