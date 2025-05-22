// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidLocationEncoding.h"

@implementation HyBidLocationEncoding

unsigned char translateEncodedChar(unsigned char c) {
    if (c >= '?') {
        switch (c) {
            case '{':
                return ('0');
            case '}':
                return ('1');
            case '|':
                return ('2');
            case '\\':
                return ('3');
            case '^':
                return ('4');
            case '~':
                return ('5');
            case '[':
                return ('6');
            case ']':
                return ('7');
            case '`':
                return ('8');
            case '@':
                return ('9');
            default:
                return (c);
        }
    }
    
#ifdef DEBUG
    switch (c) {
        case '0':
            return ('{');
        case '1':
            return ('}');
        case '2':
            return ('|');
        case '3':
            return ('\\');
        case '4':
            return ('^');
        case '5':
            return ('~');
        case '6':
            return ('[');
        case '7':
            return (']');
        case '8':
            return ('`');
        case '9':
            return ('@');
        default:
            return (c);
    }
#else
    return (c);
#endif
}
#ifdef DEBUG




+ (CLLocation *)decodeLocation:(NSString *)enc {
    int lat = 0;
    int lon = 0;
    const char *cenc = [enc cStringUsingEncoding:NSASCIIStringEncoding];
    int b;
    int i = 0;
    int shift = 0;
    int result = 0;
    
    do {
        b = translateEncodedChar(cenc[i++]) - '?';
        result |= (b & 0x1f) << shift;
        shift += 5;
    } while (b >= 0x20);
    
    lat = (((result & 1) > 0) ? ~(result >> 1) : (result >> 1));
    
    shift = result = 0;
    
    do {
        b = translateEncodedChar(cenc[i++]) - '?';
        result |= (b & 0x1f) << shift;
        shift += 5;
    } while (b >= 0x20);
    
    lon = (((result & 1) > 0) ? ~(result >> 1) : (result >> 1));
    
    CLLocation *tmp = [[CLLocation alloc]
                       initWithLatitude:(lat * 1e-5) longitude:(lon * 1e-5)];
    
    return tmp;
}
#endif




+ (NSString *)encodeLocation:(CLLocation *)loc {
    if (!loc) return (nil);
    
    
    int lat = (int)(loc.coordinate.latitude * 1e5);
    int lon = (int)(loc.coordinate.longitude * 1e5);
    
    
    if (lat < 0) { lat <<= 1; lat = ~(lat); }
    else lat <<= 1;
    
    if (lon < 0) { lon <<= 1; lon = ~(lon); }
    else lon <<= 1;
    
    NSMutableString *tmp = [NSMutableString string];
    
    while (lat >= 0x20) {
        [tmp appendFormat:@"%c", translateEncodedChar((0x20 | (lat & 0x1f)) + '?')];
        lat >>= 5;
    }
    
    [tmp appendFormat:@"%c", translateEncodedChar(lat + '?')];
    
    while (lon >= 0x20) {
        [tmp appendFormat:@"%c", translateEncodedChar((0x20 | (lon & 0x1f)) + '?')];
        lon >>= 5;
    }
    
    [tmp appendFormat:@"%c", translateEncodedChar(lon + '?')];
    
    return (tmp);
}
@end
