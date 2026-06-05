//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import "HyBidVASTParser.h"
#import "HyBidVASTIconUtils.h"

@interface HyBidVASTIconsTests : XCTestCase

@property (nonatomic, strong) HyBidVASTParser *parser;

@end

@implementation HyBidVASTIconsTests

- (void)setUp {
    self.parser = [[HyBidVASTParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
}

- (void)test_icons_value {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for request completion."];
    
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *vastError) {
        XCTAssertNotNil(vastModel);
        
        HyBidVASTAd *firstAd = [vastModel ads][0];
        HyBidVASTAd *secondAd = [vastModel ads][1];
        
        NSArray<HyBidVASTCreative *> *firstAdCreatives = [[firstAd inLine] creatives];
        NSArray<HyBidVASTCreative *> *secondAdCreatives = [[secondAd inLine] creatives];
        
        HyBidVASTCreative *firstAdSecondCreative = firstAdCreatives[1];
        
        HyBidVASTCreative *secondAdFirstCreative = secondAdCreatives[0];
        
        NSArray<HyBidVASTIcon *> *icons = [[firstAdSecondCreative linear] icons];
        HyBidVASTIcon *icon = icons.firstObject;
        
        NSArray<HyBidVASTIcon *> *iconsFromSecondAd = [[secondAdFirstCreative linear] icons];
        HyBidVASTIcon *iconFromSecondAd = iconsFromSecondAd.firstObject;

        XCTAssertNil(iconsFromSecondAd);
        XCTAssertNil(iconFromSecondAd);
    
        XCTAssertNotNil(icons);
        XCTAssertNotNil(icon);
        
        [[[HyBidVASTIconUtils alloc] init] getVASTIconFrom:vastModel.vastArray vastString: nil completion:^(NSArray<HyBidVASTIcon *> *icons, NSError *error) {
            HyBidVASTIcon *icon = [self getIconFromArray:icons];
            XCTAssertNotNil(icon);

            XCTAssertEqualObjects(icon.duration, @"00:00:16");
            XCTAssertEqualObjects(icon.program, @"AdChoices");
            XCTAssertEqualObjects(icon.width, @"20");
            XCTAssertEqualObjects(icon.height, @"16");
            XCTAssertEqualObjects(icon.xPosition, @"left");
            XCTAssertEqualObjects(icon.yPosition, @"top");
            XCTAssertEqualObjects(icon.offset, @"00:00:03");
            XCTAssertEqualObjects(icon.pxRatio, @"1");
            XCTAssertEqualObjects(icon.iconViewTracking[0].content, @"Sample_IconViewTracking_URL");
        }];
        
        XCTAssertEqual(icon.staticResources.count, 1);
        HyBidVASTStaticResource *resource = icon.staticResources.firstObject;
        XCTAssertEqualObjects(resource.creativeType, @"image/png");
        XCTAssertEqualObjects(resource.content, @"https://example.org/images/ad_icon_img.png");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];

}

- (HyBidVASTIcon *)getIconFromArray:(NSArray<HyBidVASTIcon *> *)icons {
    for(HyBidVASTIcon *icon in icons) {
        if(icon != nil &&
           [icon.staticResources count] > 0 &&
           ![icon.staticResources.firstObject.content isEqualToString:@""]) {
            return icon;
        } else {
            continue;
        }
    }
    return nil;
}


// MARK: - Helper Methods

- (NSString *)readFromTxtFileNamed:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:name ofType:@"xml"];
    
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        XCTFail(@"Error reading file: %@", error.localizedDescription);
        return nil;
    }
    
    return fileContents;
}

@end
