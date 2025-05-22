// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTModel.h"
#import "HyBidXMLEx.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidVASTModel ()

@property (nonatomic, strong)NSMutableArray *vastDocumentArray;

@property (nonatomic, strong)NSMutableArray *vastArray;

@property (nonatomic, strong)HyBidXMLEx *parser;

@end

@implementation HyBidVASTModel

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        [self addVASTDocument:data];
    }
    return self;
}

- (NSString *)version
{
    return [[self.parser rootElement] attribute:@"version"];
}

- (NSArray<HyBidVASTAd *> *)ads
{
    NSMutableArray *ads = [[NSMutableArray alloc] init];
    
    NSArray *result = [[self.parser rootElement] query:@"Ad"];
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTAd *ad = [[HyBidVASTAd alloc] initWithXMLElement:result[i]];
        [ads addObject:ad];
    }
    return ads;
}

- (HyBidVASTErrorTagURLs)errors
{
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    for (HyBidXMLElementEx *element in [[self.parser rootElement] query:@"Error"]) {
        if (element.value != nil) {
            [errors addObject:element.value];
        }
    }
    return errors;
}

// We deliberately do not declare this method in the header file in order to hide it.
// It should be used only be the VAST2Parser to build the model.
// It should not be used by anybody else receiving the model object.
- (void)addVASTDocument:(NSData *)vastDocument {
    if (!self.vastDocumentArray) {
        self.vastDocumentArray = [NSMutableArray array];
    }
    
    [self.vastDocumentArray removeAllObjects];
    [self.vastDocumentArray addObject:vastDocument];
    
    NSString *xml = [[NSString alloc] initWithData:self.vastDocumentArray[0] encoding:NSUTF8StringEncoding];
    self.parser = [HyBidXMLEx parserWithXML:xml];
}

- (void)addVASTString:(NSData *)vastString {
    if (!self.vastArray) {
        self.vastArray = [NSMutableArray array];
    }
    [self.vastArray addObject: vastString];
}

- (NSString *)vastString
{
    if (self.vastDocumentArray != nil && [self.vastDocumentArray count] > 0) {
        return [[NSString alloc] initWithData: self.vastDocumentArray[0] encoding:NSUTF8StringEncoding] ;
    }
    return nil;
}

- (void)dealloc {
    self.vastDocumentArray = nil;
    self.parser = nil;
}

@end
