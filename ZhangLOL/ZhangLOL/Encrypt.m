//
//  Encrypt.m
//  ZhangLOL
//
//  Created by mac on 17/4/22.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "Encrypt.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Encrypt
+ (NSString *)getMessageDigestMD5:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (uint32_t)strlen(cStr),digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}
@end
