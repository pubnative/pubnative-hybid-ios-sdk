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

#define MAX_ELEMENTS 100
#define MAX_ATTRIBUTES 100

#define HyBidXML_ATTRIBUTE_NAME_START 0
#define HyBidXML_ATTRIBUTE_NAME_END 1
#define HyBidXML_ATTRIBUTE_VALUE_START 2
#define HyBidXML_ATTRIBUTE_VALUE_END 3
#define HyBidXML_ATTRIBUTE_CDATA_END 4

// ================================================================================================
//  Structures
// ================================================================================================
typedef struct _HyBidXMLAttribute {
	char * name;
	char * value;
	struct _HyBidXMLAttribute * next;
} HyBidXMLAttribute;

typedef struct _HyBidXMLElement {
	char * name;
	char * text;
	
	HyBidXMLAttribute * firstAttribute;
	
	struct _HyBidXMLElement * parentElement;
	
	struct _HyBidXMLElement * firstChild;
	struct _HyBidXMLElement * currentChild;
	
	struct _HyBidXMLElement * nextSibling;
	struct _HyBidXMLElement * previousSibling;
	
} HyBidXMLElement;

typedef struct _HyBidXMLElementBuffer {
	HyBidXMLElement * elements;
	struct _HyBidXMLElementBuffer * next;
	struct _HyBidXMLElementBuffer * previous;
} HyBidXMLElementBuffer;

typedef struct _HyBidXMLAttributeBuffer {
	HyBidXMLAttribute * attributes;
	struct _HyBidXMLAttributeBuffer * next;
	struct _HyBidXMLAttributeBuffer * previous;
} HyBidXMLAttributeBuffer;

// ================================================================================================
//  HyBidXML Public Interface
// ================================================================================================
@interface HyBidXML : NSObject {
	
@private
	HyBidXMLElement * rootXMLElement;
	
	HyBidXMLElementBuffer * currentElementBuffer;
	HyBidXMLAttributeBuffer * currentAttributeBuffer;
	
	long currentElement;
	long currentAttribute;
	
	char * bytes;
	long bytesLength;
	
	BOOL invalidXML;
	NSString *parsingErrorDescription;
}

@property (nonatomic, retain) NSString *parsingErrorDescription;
@property (nonatomic, readonly) BOOL invalidXML;
@property (nonatomic, readonly) HyBidXMLElement * rootXMLElement;

+ (id)HyBidXMLWithURL:(NSURL*)aURL;
+ (id)HyBidXMLWithXMLString:(NSString*)aXMLString;
+ (id)HyBidXMLWithXMLData:(NSData*)aData;
+ (id)HyBidXMLWithXMLFile:(NSString*)aXMLFile;
+ (id)HyBidXMLWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension;

- (id)initWithURL:(NSURL*)aURL;
- (id)initWithXMLString:(NSString*)aXMLString;
- (id)initWithXMLData:(NSData*)aData;
- (id)initWithXMLFile:(NSString*)aXMLFile;
- (id)initWithXMLFile:(NSString*)aXMLFile fileExtension:(NSString*)aFileExtension;

@end

// ================================================================================================
//  HyBidXML Static Functions Interface
// ================================================================================================

@interface HyBidXML (StaticFunctions)

+ (NSString*) elementName:(HyBidXMLElement*)aXMLElement;
+ (NSString*) textForElement:(HyBidXMLElement*)aXMLElement;
+ (NSString*) valueOfAttributeNamed:(NSString *)aName forElement:(HyBidXMLElement*)aXMLElement;

+ (NSString*) attributeName:(HyBidXMLAttribute*)aXMLAttribute;
+ (NSString*) attributeValue:(HyBidXMLAttribute*)aXMLAttribute;

+ (HyBidXMLElement*) nextSiblingNamed:(NSString*)aName searchFromElement:(HyBidXMLElement*)aXMLElement;
+ (HyBidXMLElement*) childElementNamed:(NSString*)aName parentElement:(HyBidXMLElement*)aParentXMLElement;

@end
