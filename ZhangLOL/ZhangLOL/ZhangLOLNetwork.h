//
//  ZhangLOLNetwork.h
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZhangLOLNetwork : NSObject

+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress *downloadProgress))downloadProgress
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failure;

@end
