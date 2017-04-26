//
//  CacheManager.h
//  ZhangLOL
//
//  Created by mac on 17/4/11.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

+ (void)defaultSettingSDImageCache;

/**
 清空当前内存中的图片缓存
 */
+ (void)cleanAllImageCacheFromMemory;

/**
 清空当前内存中对应模型的图片缓存

 @param models 模型数组
 */
+ (void)cleanImageCacheFromMemoryWithModels:(NSArray *)models;

/**
 清空当前沙盒中的图片缓存
 */
+ (void)cleanAllImageCacheFromDiskWithCompletion:(void(^)())block;


/**
 异步计算沙盒中图片缓存大小

 @param block 回调
 */
+ (void)calculateDiskCacheSizeWithCompletionBlock:(void(^)(NSUInteger imageCount, NSUInteger size))block;

@end
