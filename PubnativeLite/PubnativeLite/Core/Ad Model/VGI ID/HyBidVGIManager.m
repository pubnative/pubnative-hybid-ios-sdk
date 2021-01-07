//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidVGIManager.h"
#import "HyBidKeychain.h"

@implementation HyBidVGIManager

#define kHyBid_VGI_ID @"HyBid_VGI_ID"

-(HyBidVGIModel *)getHyBidVGIModel
{
//    NSString *vgiID = (NSString *)[HyBidKeychain loadObjectForKey:kHyBid_VGI_ID];
    NSString *vgiID = @"{\"apps\":[{\"bundle_id\":\"123\",\"users\":[{\"AUID\":\"1\",\"SUID\":\"2\",\"vendors\":{\"APL\":{\"IDFV\":\"3\"},\"LR\":{\"IDL\":\"4\"},\"TTD\":{\"IDL\":\"5\"}}}],\"privacy\":{\"lat\":\"6\",\"tcfv1\":\"7\",\"tcfv2\":\"8\",\"iab_ccpa\":\"9\"}}],\"device\":{\"id\":\"1\",\"os\":{\"name\":\"2\",\"version\":\"3\",\"build_signature\":\"4\"},\"manufacture\":\"5\",\"model\":\"6\",\"brand\":\"7\",\"battery\":{\"capacity\":\"8\"}},\"users\":[{\"SUID\":\"9\",\"emails\":[{\"bundle_id\":\"1\"}],\"vendors\":{\"GGL\":{\"GAID\":\"2\"},\"APL\":{\"IDFA\":\"3\"}},\"locations\":[{\"bundle_id\":\"4\"}],\"audiences\":[{\"bundle_id\":\"5\"}]}]}";

    HyBidVGIModel *model = nil;
    id jsonObject = nil;
    
    if (vgiID != nil && [vgiID length] != 0) {
        NSData *jsonData = [vgiID dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        model = [[HyBidVGIModel alloc] initWithJSON:jsonObject];
        
        [self setHyBidVGIModelFrom:model];
    }

    return model;
}

- (void)setHyBidVGIModelFrom:(HyBidVGIModel *)model
{
    if (model != nil) {
        NSError *writeError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:model.dictionary options:NSJSONWritingPrettyPrinted error:&writeError];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [HyBidKeychain saveObject:jsonString forKey:kHyBid_VGI_ID];
    }
}

@end
