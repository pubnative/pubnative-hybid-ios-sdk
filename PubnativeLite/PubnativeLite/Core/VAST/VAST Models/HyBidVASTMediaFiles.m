// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTMediaFiles.h"
#import "HyBidVASTMediaFile.h"

@interface HyBidVASTMediaFiles ()

@property (nonatomic, strong)HyBidXMLElementEx *mediaFilesXMLElement;

@end

@implementation HyBidVASTMediaFiles

- (instancetype)initWithMediaFilesXMLElement:(HyBidXMLElementEx *)mediaFilesXMLElement
{
    if (mediaFilesXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.mediaFilesXMLElement = mediaFilesXMLElement;
    }
    return self;
}

- (NSArray<HyBidVASTMediaFile *> *)mediaFiles
{
    NSString *query = @"/MediaFile";
    NSArray<HyBidXMLElementEx *> *result = [self.mediaFilesXMLElement query:query];
    NSMutableArray<HyBidVASTMediaFile *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTMediaFile *mediaFile = [[HyBidVASTMediaFile alloc] initWithMediaFileXMLElement:result[i]];
        [array addObject:mediaFile];
    }
    
    return array;
}

- (NSArray<HyBidVASTInteractiveCreativeFile *> *)interactiveCreativeFiles
{
    NSString *query = @"/InteractiveCreativeFile";
    NSArray<HyBidXMLElementEx *> *result = [self.mediaFilesXMLElement query:query];
    NSMutableArray<HyBidVASTInteractiveCreativeFile *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTInteractiveCreativeFile *interactiveCreativeFile = [[HyBidVASTInteractiveCreativeFile alloc] initWithInteractiveCreativeFileXMLElement:result[i]];
        [array addObject:interactiveCreativeFile];
    }
    
    return array;
}

@end
