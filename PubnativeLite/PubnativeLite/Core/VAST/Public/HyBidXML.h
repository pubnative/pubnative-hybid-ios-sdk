// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
