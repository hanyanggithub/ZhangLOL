//
//  LoggerManager.h
//  ZhangLOL
//
//  Created by mac on 17/4/27.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoggerManager : NSObject
+ (void)monitorException;
+ (void)upLoadLogIfNeeded;
@end
