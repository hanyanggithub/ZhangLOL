//
//  ZhangLOLNetwork.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "ZhangLOLNetwork.h"
#import <AFNetworking.h>

@interface ZhangLOLNetwork ()

@property(nonatomic, strong)AFHTTPSessionManager *manager;

@end

static ZhangLOLNetwork *singleton;

@implementation ZhangLOLNetwork

+ (ZhangLOLNetwork *)singleton {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
        singleton.manager = [AFHTTPSessionManager manager];
        singleton.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
    });
    return singleton;
}

+ (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    ZhangLOLNetwork *obj = [self singleton];
    NSURLSessionDataTask *task = [obj.manager GET:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
    return task;
}

@end
