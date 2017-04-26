//
//  LoggerManager.m
//  ZhangLOL
//
//  Created by mac on 17/4/27.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "LoggerManager.h"
#import "Logger.h"

#define CRASH_LOG_PATH @"/Documents/CrashLog/"

@implementation LoggerManager
+ (void)monitorException {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *orgPath = [NSString stringWithFormat:@"%@/Documents/CrashLog",NSHomeDirectory()];
    BOOL dir;
    if (![fileManager fileExistsAtPath:orgPath isDirectory:&dir]) {
        [fileManager createDirectoryAtPath:orgPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [Logger monitorExceptionWithHandler:^(NSException *exception) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:exception.name forKey:@"name"];
        [dic setObject:exception.reason forKey:@"reason"];
        if (exception.userInfo) {
            [dic setObject:exception.userInfo forKey:@"userInfo"];
        }
        if (exception.callStackReturnAddresses) {
            [dic setObject:exception.callStackReturnAddresses forKey:@"callStackReturnAddresses"];
        }
        if (exception.callStackSymbols) {
            [dic setObject:exception.callStackSymbols forKey:@"callStackSymbols"];
        }
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd hh:mm:ss";
        NSString *dateStr = [dateFormatter stringFromDate:date];
        NSString *path = [NSString stringWithFormat:@"%@/%@",orgPath,dateStr];
        [dic writeToFile:path atomically:NO];
    }];
}
+ (void)upLoadLogIfNeeded {
    
}
@end
