//
//  Logger.m
//  ZhangLOL
//
//  Created by mac on 17/4/27.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "Logger.h"
#import <objc/runtime.h>
#include <libkern/OSAtomic.h>

const char * handlerKey = "handlerKey";
const int32_t uncaughtExceptionMaximum = 10;

@implementation Logger

static Logger *sharedLogger() {
    static Logger* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Logger alloc] init];
        
    });
    return instance;
}

void exceptionHandler(NSException *exception) {
    volatile int32_t _uncaughtExceptionCount = 0;
    int32_t exceptionCount = OSAtomicIncrement32(&_uncaughtExceptionCount);
    if (exceptionCount > uncaughtExceptionMaximum) {
        return;
    }
    Logger *logger = sharedLogger();
    void(^block)(NSException *) = objc_getAssociatedObject(logger, handlerKey);
    block(exception);
}


+ (void)monitorExceptionWithHandler:(void(^)(NSException *exception))block {
    if (block) {
        Logger *logger = sharedLogger();
        objc_setAssociatedObject(logger, handlerKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
        NSSetUncaughtExceptionHandler(&exceptionHandler);
    }
}


@end
