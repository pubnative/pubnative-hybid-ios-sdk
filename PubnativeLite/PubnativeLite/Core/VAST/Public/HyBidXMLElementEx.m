// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidXMLElementEx.h"

@interface HyBidXMLElementEx() 
-(HyBidXMLElementEx *) duplicate;
@end

@implementation HyBidXMLElementEx
@synthesize attributes;

-(id) initWithElement:(HyBidXMLElement *) value {
	if (self = [super init]) {
		element = value;
		firstPass = YES;
	}
	
	return self;
}

-(NSDictionary *) attributes {
	if (!attributes) {
		attributes = [[NSMutableDictionary alloc] init];
		HyBidXMLAttribute *attr = element->firstAttribute;
		
		while (attr) {
			[attributes setObject:[HyBidXML attributeValue:attr] forKey:[HyBidXML attributeName:attr]];
			attr = attr->next;
		}
	}
	
	return attributes;
}

-(NSArray *) query:(NSString *) search {
	NSMutableArray *result = [NSMutableArray array];
	NSArray *parts = [search componentsSeparatedByString:@"/"];
	NSString *targetElementName = [[parts objectAtIndex:parts.count - 1] lowercaseString];

	if ([targetElementName isEqualToString:@""]) {
		if (parts.count == 1) {
			return result;
		}
		
		targetElementName = [parts objectAtIndex:parts.count - 2];
	}
	
	int index = 0;
	HyBidXMLElementEx *el = nil;
	NSString *piece = [parts objectAtIndex:index];
	
	if ([piece isEqualToString:@""]) {
		el = [self child:[parts objectAtIndex:1]];
		index = 1;
	}
	else {
		el = [self child:piece];
	}
	
	BOOL didFindElement = [el.name isEqualToString:targetElementName];
	
	while (el != nil && index < parts.count && !didFindElement) {
		if ([el.name isEqualToString:targetElementName]) {
			didFindElement = YES;
		}
		else {
			piece = [parts objectAtIndex:++index];
			
			if (![piece isEqualToString:@""]) {
				el = [el child:piece];
			}
		}
	}
	
	if (didFindElement) {
		while ([el next]) {
			[result addObject:[el duplicate]];
		}
	}
	
	return result;
}

-(HyBidXMLElementEx *) duplicate {
	return [[HyBidXMLElementEx alloc] initWithElement:element];
}

-(NSString *) name {
	return element ? [HyBidXML elementName:element] : nil;
}

-(int) intAttribute:(NSString *) name {
	return element ? [[self attribute:name] intValue] : 0;
}

-(long long) longAttribute:(NSString *) name {
	return element ? [[self attribute:name] longLongValue] : 0; 
}

-(NSString *) attribute:(NSString *) name {
	return element ? [HyBidXML valueOfAttributeNamed:name.lowercaseString forElement:element] : nil;
}

-(int) intValue {
	return [[self value] intValue];
}

-(long long) longValue {
	return [[self value] longLongValue];
}

-(NSString *) value {
    NSString *string = element ? [HyBidXML textForElement:element] : nil;
    NSString *decodedString = [self replaceHtmlEntitiesIfNeededFrom:string];
    
    return decodedString;
}

- (NSString *)replaceHtmlEntitiesIfNeededFrom:(NSString *)string
{
    NSString *decodedString = string;
    NSDictionary *htmlEntities = @{
        @"&lt;" : @"<",
        @"&gt;" : @">",
        @"&amp;" : @"&",
        @"&#34;" : @"\"",
        @"&#39;" : @"'",
        @"&#xA;" : @"",
    };
    
    for (NSString *entityCode in htmlEntities.allKeys) {
        NSString *character = htmlEntities[entityCode];
        decodedString = [decodedString stringByReplacingOccurrencesOfString:entityCode withString:character];
    }
    
    return decodedString;
}

-(NSString *) text {
	return [self value];
}

-(BOOL) next {
	if (!element) {
		return NO;
	}
	
	if (firstPass) {
		firstPass = NO;
		return YES;
	}
	
	element = [HyBidXML nextSiblingNamed:[HyBidXML elementName:element].lowercaseString searchFromElement:element];
	return element != nil;
}

-(HyBidXMLElementEx *) child:(NSString *) elementName {
	HyBidXMLElement *childElement = [HyBidXML childElementNamed:elementName.lowercaseString parentElement:element];
	return childElement ? [[HyBidXMLElementEx alloc] initWithElement:childElement] : nil;
}

@end
