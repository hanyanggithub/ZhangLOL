//
//  CacheManager.m
//  ZhangLOL
//
//  Created by mac on 17/4/11.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "CacheManager.h"
#import "SmallCellModel.h"
#import "SpecialModel.h"

@implementation CacheManager

+ (void)defaultSettingSDImageCache {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    // 设置沙盒路径
    [cache makeDiskCachePath:IMAGE_DISK_CACHE_PATH];
    cache.maxMemoryCountLimit = 50;
}

+ (void)cleanAllImageCacheFromMemory {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearMemory];
}

+ (void)cleanImageCacheFromMemoryWithModels:(NSArray *)models {
    if (models == nil || models.count == 0) {
        return;
    }
    if (![models[0] isKindOfClass:[BaseModel class]]) {
        return;
    }
    if ([models[0] isKindOfClass:[SmallCellModel class]]) {
        [self cleanSmallCellModelImageCacheWithModels:models];
    }else if ([models[0] isKindOfClass:[SpecialModel class]]) {
        [self cleanSpecialModelImageCacheWithModels:models];
    }else{
        
    }
}
+ (void)cleanSmallCellModelImageCacheWithModels:(NSArray *)models {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    for (SmallCellModel *model in models) {
        if (model.image_url_big) {
            [cache removeImageForKey:model.image_url_big fromDisk:NO withCompletion:nil];
        }
        if (model.image_url_small) {
            [cache removeImageForKey:model.image_url_big fromDisk:NO withCompletion:nil];
        }
        if (model.teama_logo) {
            [cache removeImageForKey:model.teama_logo fromDisk:NO withCompletion:nil];
        }
        if (model.teamb_logo) {
            [cache removeImageForKey:model.teamb_logo fromDisk:NO withCompletion:nil];
        }
        if (model.count_image_url) {
            [cache removeImageForKey:model.count_image_url fromDisk:NO withCompletion:nil];
        }
        if (model.big_image_url) {
            [cache removeImageForKey:model.big_image_url fromDisk:NO withCompletion:nil];
        }
        if (model.small_image_url) {
            [cache removeImageForKey:model.small_image_url fromDisk:NO withCompletion:nil];
        }
    }
    
}

+ (void)cleanSpecialModelImageCacheWithModels:(NSArray *)models {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    for (SpecialModel *model in models) {
        if (model.logo) {
            [cache removeImageForKey:model.logo fromDisk:NO withCompletion:nil];
        }
    }
}
+ (void)cleanAllImageCacheFromDiskWithCompletion:(void(^)())block {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearDiskOnCompletion:^{
        block();
    }];
}
+ (void)calculateDiskCacheSizeWithCompletionBlock:(void(^)(NSUInteger imageCount, NSUInteger size))block {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        block(fileCount,totalSize);
    }];
}

@end
