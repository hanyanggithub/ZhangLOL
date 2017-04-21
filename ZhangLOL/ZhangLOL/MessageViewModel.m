//
//  MessageViewModel.m
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "MessageViewModel.h"
#import "RencommendModel.h"
#import "ChannelModel.h"
#import "SmallCellModel.h"
#import "SpecialModel.h"

@interface MessageViewModel ()

@end


@implementation MessageViewModel

- (NSMutableArray *)channelModels {
    if (_channelModels == nil) {
        _channelModels = [NSMutableArray array];
    }
    return _channelModels;
}
- (NSMutableArray *)rencommendModels {
    if (_rencommendModels == nil) {
        _rencommendModels = [NSMutableArray array];
    }
    return _rencommendModels;
}
- (NSMutableDictionary *)allChannelsModelDic {
    if (_allChannelsModelDic == nil) {
        _allChannelsModelDic = [NSMutableDictionary dictionary];
    }
    return _allChannelsModelDic;
}
- (NSMutableArray *)tagedModels {
    if (_tagedModels == nil) {
        _tagedModels = [NSMutableArray array];
    }
    return _tagedModels;
}


- (void)requestChannelData:(NSString *)url
                   success:(void (^)(NSURLSessionDataTask *task, NSArray *models))successHandler
                   failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler {
    
    [ZhangLOLNetwork GET:url parameters:nil progress:^(NSProgress *downloadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        self.channelModels = nil;
        for (NSDictionary *dic in responseObject) {
            ChannelModel *model = [[ChannelModel alloc] initWithDic:dic];
            [self.channelModels addObject:model];
        }
        NSArray *newArray = [NSArray arrayWithArray:self.channelModels];
        successHandler(task,newArray);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureHandler(task,error);
    }];
}


- (void)requestRecommendData:(NSString *)url
                     success:(void (^)(NSURLSessionDataTask *task, NSArray *models))successHandler
                     failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler {
    
    [ZhangLOLNetwork GET:url parameters:nil progress:^(NSProgress *downloadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *array = responseObject[@"list"];
        self.rencommendModels = nil;
        for (NSDictionary *dic in array) {
            RencommendModel *model = [[RencommendModel alloc] initWithDic:dic];
            [self.rencommendModels addObject:model];
        }
        NSArray *newArray = [NSArray arrayWithArray:self.rencommendModels];
        successHandler(task,newArray);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureHandler(task,error);
    }];
}


- (NSURLSessionDataTask *)requestDataWithChannelModel:(ChannelModel *)channelModel
                                                 page:(NSString *)page
                                       automaticMerge:(BOOL)merge
                                              success:(void (^)(ChannelModel *channelModel, NSArray *models))successHandler
                                              failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *url = nil;
    if ([channelModel.chnl_type isEqualToString:@"col"]) {
        if (page.integerValue != 0) {
            // 判断是否可以加载更多
            NSMutableArray *originData = [self.allChannelsModelDic objectForKey:channelModel.channel_id];
            if (originData) {
                NSArray *any = [originData lastObject];
                SpecialModel *specialModel = [any lastObject];
                if (!specialModel.hasnext) {
                    return nil;
                }
            }
        }
        
        // 专题类型
        url = MESSAGE_SPECIAL_PATH;
        [parameters setObject:@"9681" forKey:@"version"];
    }else{
        // 其他类型
        url = MESSAGE_GETNEWS_PATH;
        [parameters setObject:channelModel.channel_id forKey:@"id"];
        [parameters setObject:@"33" forKey:@"version"];
    }
    [parameters setObject:page forKey:@"page"];
    [parameters setObject:@"ios" forKey:@"plat"];
    
    NSURLSessionDataTask *task = [ZhangLOLNetwork GET:url parameters:parameters progress:^(NSProgress *downloadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        // 处理数据
        NSMutableArray *arrays = [self dealDataWithResponseObject:responseObject channelModel:channelModel];
        // 是否合并
        if (merge) {
            // 数据合并处理
            NSMutableArray *mergedArrays = nil;
            if (page.intValue == 0) {
                // 刷新或者是首次请求
                mergedArrays = [self mergeModelDataArrayWithChannelModel:channelModel newModels:arrays isFront:YES];
            }else{
                // 加载更多数据
                mergedArrays = [self mergeModelDataArrayWithChannelModel:channelModel newModels:arrays isFront:NO];
            }
            if (mergedArrays) {
                arrays = mergedArrays;
            }
            // 数据备份
            [self.allChannelsModelDic setObject:arrays forKey:channelModel.channel_id];
        }
        // 返回上层
        successHandler(channelModel,arrays);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureHandler(task,error);
    }];
    return task;
}


/**
 数据解析

 @param responseObject 服务器返回的json
 @param model 频道模型
 @return result
 */
- (NSMutableArray *)dealDataWithResponseObject:(id)responseObject channelModel:(ChannelModel *)model {
    NSMutableArray *arrays = [NSMutableArray array];
    if ([model.chnl_type isEqualToString:@"col"]) {
        // 专题类型
        NSMutableArray *unbook = responseObject[@"unbook_list"];
        NSMutableArray *book = responseObject[@"book_list"];
        NSMutableArray *recommend = responseObject[@"recommend_list"];
        NSString *hasNext = responseObject[@"hasnext"];
        
        NSMutableArray *unbookModels = [NSMutableArray array];
        NSMutableArray *bookModels = [NSMutableArray array];
        NSMutableArray *recommendModels = [NSMutableArray array];
        for (NSDictionary *dic in recommend) {
            SpecialModel *model = [[SpecialModel alloc] initWithDic:dic];
            model.type = SpecialTypeRecommend;
            model.hasnext = hasNext.boolValue;
            [recommendModels addObject:model];
        }
        for (NSDictionary *dic in book) {
            SpecialModel *model = [[SpecialModel alloc] initWithDic:dic];
            model.type = SpecialTypeBook;
            model.hasnext = hasNext.boolValue;
            [bookModels addObject:model];
        }
        for (NSDictionary *dic in unbook) {
            SpecialModel *model = [[SpecialModel alloc] initWithDic:dic];
            model.type = SpecialTypeUnbook;
            model.hasnext = hasNext.boolValue;
            [unbookModels addObject:model];
        }
        [arrays addObject:recommendModels];
        [arrays addObject:bookModels];
        [arrays addObject:unbookModels];
    }else{
        // 其他类型
        NSArray *array = responseObject[@"list"];
        for (NSDictionary *dic in array) {
            SmallCellModel *model = [[SmallCellModel alloc] initWithDic:dic];
            [arrays addObject:model];
        }
    }
    return arrays;
}


/**
 拼接更多数据的模型数组

 @param model 当前频道的模型
 @param array 新的模型数组
 @param front 是否在前边拼接
 @return 拼接完成的数组
 */
- (NSMutableArray *)mergeModelDataArrayWithChannelModel:(ChannelModel *)model newModels:(NSMutableArray *)array isFront:(BOOL)front {
    // 获取原数据
    NSMutableArray *originData = [self.allChannelsModelDic objectForKey:model.channel_id];
    
    if (originData) {
        if (!front) {
            
            if ([model.chnl_type isEqualToString:@"col"]) {
                for (NSMutableArray *subArray in array) {
                    NSInteger index = [array indexOfObject:subArray];
                    ;
                    NSMutableArray *originSubData = originData[index];
                    [originSubData addObjectsFromArray:subArray];
                }
            }else{
                // 1.替换本地点击过的cellModel
                NSMutableArray *disposedArray = [self disposeModels:array];
                // 2.拼接
                [originData addObjectsFromArray:disposedArray];
            }
        }else{
            
            if ([model.chnl_type isEqualToString:@"col"]) {
                for (NSMutableArray *subArray in array) {
                    NSInteger index = [array indexOfObject:subArray];
                    ;
                    NSMutableArray *originSubData = originData[index];
                    
                    // 获取原数据中时间结点最后的一条
                    SpecialModel *orgNewetModel = [originSubData firstObject];
                    for (NSInteger i = subArray.count -1; i < subArray.count; i--) {
                        SpecialModel *everyNewModel = subArray[i];
                        // 比较顺序
                        int oldT = [self getTimeIntervalSinceNow:orgNewetModel.last_update];
                        int newT = [self getTimeIntervalSinceNow:everyNewModel.last_update];
                        if (newT < oldT) {
                            [originSubData insertObject:everyNewModel atIndex:0];
                        }
                    }
                }
            }else{
                SmallCellModel *orgNewetModel = [originData firstObject];
                for (NSInteger i = array.count -1; i < array.count; i--) {
                    SmallCellModel *everyNewModel = array[i];
                    // 比较顺序
                    int oldT = [self getTimeIntervalSinceNow:orgNewetModel.publication_date];
                    int newT = [self getTimeIntervalSinceNow:everyNewModel.publication_date];
                    if (newT < oldT) {
                        [originData insertObject:everyNewModel atIndex:0];
                    }
                }
                // 1.替换本地点击过的cellModel
                originData = [self disposeModels:originData];
                
            }
            
        }
        
    }
    return originData;
}

/**
 对新请求的数据模型去重(消息的阅读状态)

 @param models 新加入的模型
 @return 去重后的模型
 */
- (NSMutableArray *)disposeModels:(NSMutableArray *)models {
    // 过滤标记态
    if (self.tagedModels != nil) {
        for (SmallCellModel *model_new in models) {
            for (SmallCellModel *model_taged in self.tagedModels) {
                if ([model_new.article_id isEqualToString:model_taged.article_id]) {
                    model_new.isRead = YES;
                }
            }
        }
    }
    return models;
}

- (void)saveModelTag:(SmallCellModel *)model {
    if (model && model.isRead == NO) {
        model.isRead = YES;
        [self.tagedModels addObject:model];
        // 遍历已缓存的model
        for (NSArray *array in self.allChannelsModelDic.allValues) {
            id frist = [array firstObject];
            if ([frist isKindOfClass:[SmallCellModel class]]) {
                for (SmallCellModel *emodel in array) {
                    if ([model.article_id isEqualToString:emodel.article_id]) {
                        emodel.isRead = YES;
                    }
                }
            }
        }
    }
}
- (void)removeModelTag:(SmallCellModel *)model {
    if (model) {
        [self.tagedModels removeObject:model];
    }
}

- (int)getTimeIntervalSinceNow:(NSString *)dateStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *pub_date = [formatter dateFromString:dateStr];
    int p = ABS(pub_date.timeIntervalSinceNow);
    return p;
}


@end
