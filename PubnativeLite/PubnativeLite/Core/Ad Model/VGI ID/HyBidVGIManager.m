// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIManager.h"
#import "HyBidKeychain.h"
#import "HyBidUserDataManager.h"
#import <CoreLocation/CoreLocation.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidVGIManager

#define kHyBid_VGI_ID @"HyBid_VGI_ID"

+(HyBidVGIModel *)getHyBidVGIModel
{
    NSString *vgiID = (NSString *)[HyBidKeychain loadObjectForKey:kHyBid_VGI_ID];

    HyBidVGIModel *model = nil;
    id jsonObject = nil;
    
    if (vgiID != nil && [vgiID length] != 0) {
        NSData *jsonData = [vgiID dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        model = [[HyBidVGIModel alloc] initWithJSON:jsonObject];
    } else {
        model = [self generateVGIModel];
        [self setHyBidVGIModelFrom:model];
    }

    return model;
}

+(HyBidVGIModel *)generateVGIModel
{
    HyBidVGIModel *model = [[HyBidVGIModel alloc] init];
    model.apps = [self getHyBidVGIApp];
    model.device = [self getHyBidVGIDevice];
    model.users = [self getHyBidVGIUsers];
    
    return model;
}

+(NSArray<HyBidVGIApp *> *)getHyBidVGIApp
{
    NSMutableArray *appsArray = [[NSMutableArray alloc] init];
    
    HyBidVGIApp *app = [[HyBidVGIApp alloc] init];
    
    HyBidVGIPrivacy *privacy = [[HyBidVGIPrivacy alloc] init];
    privacy.lat = [HyBidSettings sharedInstance].advertisingId;
    privacy.TCFv2 = [[[HyBidUserDataManager alloc] init] getIABGDPRConsentString];
    privacy.iabCCPA = [[[HyBidUserDataManager alloc] init] getIABUSPrivacyString];
    
    app.privacy = privacy;
    app.bundleID = [HyBidSettings sharedInstance].appBundleID;
    [appsArray addObject:app];
    
    return appsArray;
}

+(HyBidVGIDevice *)getHyBidVGIDevice
{
    HyBidVGIDevice *newDevice = [[HyBidVGIDevice alloc] init];
    UIDevice *device = [[UIDevice alloc] init];
    
    newDevice.ID = [[device identifierForVendor] UUIDString];
    newDevice.manufacture = @"Apple";
    newDevice.brand = @"Apple";
    newDevice.model = [device model];
    
    HyBidVGIOS *os = [[HyBidVGIOS alloc] init];
    os.name = [device systemName];
    os.buildSignature = [self getDeviceBuildID];
    os.version = [device systemVersion];
    
    HyBidVGIBattery *battery = [[HyBidVGIBattery alloc] init];
    battery.capacity = [NSString stringWithFormat:@"%f", [device batteryLevel]];
                    
    newDevice.OS = os;
    newDevice.battery = battery;
    
    return newDevice;
}

+(NSArray<HyBidVGIUser *> *)getHyBidVGIUsers
{
    NSMutableArray<HyBidVGIUser *> *users = [[NSMutableArray alloc] init];
    
    HyBidVGIUser *user = [[HyBidVGIUser alloc] init];
    
    HyBidVGIGgl *GGL = [[HyBidVGIGgl alloc] init];
    GGL.GAID = [HyBidSettings sharedInstance].advertisingId;
    
    NSMutableArray<HyBidVGILocation *> *locations = [[NSMutableArray alloc] init];
    HyBidVGILocation *location = [[HyBidVGILocation alloc] init];
    CLLocation* clLocation = [HyBidSettings sharedInstance].location;
    
    if (location != nil) {
        location.lat = [[NSString alloc] initWithFormat:@"%.2f", clLocation.coordinate.latitude];
        location.lon = [[NSString alloc] initWithFormat:@"%.2f", clLocation.coordinate.longitude];
        location.accuracy = [[NSString alloc] initWithFormat:@"%f", [clLocation horizontalAccuracy]];
        location.ts = [[NSString alloc] initWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        
        [locations addObject:location];
    }
    
    HyBidVGIUserVendor *vendor = [[HyBidVGIUserVendor alloc] init];
    vendor.GGL = GGL;
    
    user.locations = locations;
    user.vendor = vendor;
    
    [users addObject:user];
    
    return users;
}

+(NSString *)getDeviceBuildID
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    return [infoDict objectForKey:@"CFBundleVersion"];
}

+(void)setHyBidVGIModelFrom:(HyBidVGIModel *)model
{
    if (model != nil) {
        NSError *writeError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:model.dictionary options:NSJSONWritingPrettyPrinted error:&writeError];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [HyBidKeychain saveObject:jsonString forKey:kHyBid_VGI_ID];
    }
}

@end
