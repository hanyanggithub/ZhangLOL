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

@property(nonatomic, strong)AFHTTPSessionManager *httpManager;
@property(nonatomic, strong)AFHTTPSessionManager *urlManager;
@end

static ZhangLOLNetwork *singleton;

@implementation ZhangLOLNetwork

+ (ZhangLOLNetwork *)singleton {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
        singleton.httpManager = [AFHTTPSessionManager manager];
        singleton.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];

        
        AFHTTPResponseSerializer *responseSerialier = [AFHTTPResponseSerializer serializer];
        responseSerialier.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        singleton.urlManager = [AFHTTPSessionManager manager];
        singleton.urlManager.responseSerializer = responseSerialier;
    });
    return singleton;
}

+ (NSURLSessionDataTask *)HTML:(NSString *)URLString
                            parameters:(id)parameters
                              progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(void (^)(NSURLSessionDataTask *task, id  responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    ZhangLOLNetwork *obj = [self singleton];
    NSURLSessionDataTask *task = [obj.urlManager GET:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
    return task;
}

+ (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    ZhangLOLNetwork *obj = [self singleton];
    NSURLSessionDataTask *task = [obj.httpManager GET:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
    return task;
}

+ (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *  filePath, NSError * error))completionHandler {
    ZhangLOLNetwork *obj = [self singleton];
    NSURLSessionDownloadTask *task = [obj.httpManager downloadTaskWithRequest:request progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    [task resume];
    return task;
}

@end
