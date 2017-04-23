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
@property(nonatomic, strong)AFHTTPSessionManager *httpForResponseSerializerHtmlManager;
@property(nonatomic, strong)AFNetworkReachabilityManager *reachability;
@property(nonatomic, assign)ZhangLOLReachabilityStatus reachabilityStatus;
@property(nonatomic, assign)ZhangLOLReachabilityStatus priorReachabilityStatus;
@property(nonatomic, copy)void(^netChangeBlock)(ZhangLOLReachabilityStatus changeBlock);
@end

static ZhangLOLNetwork *singleton;

@implementation ZhangLOLNetwork

+ (ZhangLOLNetwork *)singleton {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
        singleton.httpManager = [AFHTTPSessionManager manager];
        singleton.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        
        AFHTTPResponseSerializer *dataResponseSerializer = [AFHTTPResponseSerializer serializer];
        dataResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        singleton.httpForResponseSerializerHtmlManager = [AFHTTPSessionManager manager];
        singleton.httpForResponseSerializerHtmlManager.responseSerializer = dataResponseSerializer;
    });
    return singleton;
}

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                     progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failure {
    ZhangLOLNetwork *obj = [self singleton];
    NSURLSessionDataTask *task = [obj.httpForResponseSerializerHtmlManager GET:URLString parameters:nil progress:downloadProgress success:success failure:failure];
    return task;
}

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failure {
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
- (AFNetworkReachabilityManager *)reachability {
    if (_reachability == nil) {
        _reachability = [AFNetworkReachabilityManager sharedManager];
    }
    return _reachability;
}
+ (void)startMonitoring {
    ZhangLOLNetwork *obj = [self singleton];
    __weak typeof(obj) weakPointer = obj;
    [obj.reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        weakPointer.priorReachabilityStatus =  weakPointer.reachabilityStatus;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                weakPointer.reachabilityStatus = ZhangLOLReachabilityStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                weakPointer.reachabilityStatus = ZhangLOLReachabilityStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                weakPointer.reachabilityStatus = ZhangLOLReachabilityStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                weakPointer.reachabilityStatus = ZhangLOLReachabilityStatusReachableViaWiFi;
                break;
            default:
                break;
        }
        if (weakPointer.netChangeBlock) {
            weakPointer.netChangeBlock(weakPointer.reachabilityStatus);
        }
    }];
    [obj.reachability startMonitoring];
}
+ (BOOL)netUsable {
    ZhangLOLNetwork *obj = [self singleton];
    if (obj.reachabilityStatus == ZhangLOLReachabilityStatusReachableViaWWAN || obj.reachabilityStatus == ZhangLOLReachabilityStatusReachableViaWiFi) {
        return YES;
    }else{
        return NO;
    }
}
+ (ZhangLOLReachabilityStatus)currentNetStatus {
    return [self singleton].reachabilityStatus;
}
+ (ZhangLOLReachabilityStatus)priorNetStatus {
    return [self singleton].priorReachabilityStatus;
}
+ (void)setReachabilityStatusChangeBlock:(nullable void (^)(ZhangLOLReachabilityStatus status))block {
    ZhangLOLNetwork *obj = [self singleton];
    obj.netChangeBlock = block;
}

@end
