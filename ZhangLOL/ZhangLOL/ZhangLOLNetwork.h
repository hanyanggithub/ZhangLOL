//
//  ZhangLOLNetwork.h
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZhangLOLReachabilityStatus) {
    ZhangLOLReachabilityStatusUnknown          = -1,
    ZhangLOLReachabilityStatusNotReachable     = 0,
    ZhangLOLReachabilityStatusReachableViaWWAN = 1,
    ZhangLOLReachabilityStatusReachableViaWiFi = 2,
};


@interface ZhangLOLNetwork : NSObject

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failure;


+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                     progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failure;

+ (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *  filePath, NSError * error))completionHandler;

+ (void)startMonitoring;

+ (void)setReachabilityStatusChangeBlock:(void (^)(ZhangLOLReachabilityStatus status))block;

+ (BOOL)netUsable;

+ (ZhangLOLReachabilityStatus)currentNetStatus;

+ (ZhangLOLReachabilityStatus)priorNetStatus;

@end
