//
//  Logger.h
//  ZhangLOL
//
//  Created by mac on 17/4/27.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject

+ (void)monitorExceptionWithHandler:(void(^)(NSException *exception))block;

@end
