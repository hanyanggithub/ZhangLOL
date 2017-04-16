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
        // test
//        [self.channelModels removeObjectAtIndex:2];
//        [self.channelModels removeObjectAtIndex:2];
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
        NSMutableArray *arrays = [self dealDataWithResponseObject:responseObject channelModel:channelModel];
        if (merge) {
            NSMutableArray *mergedArrays = [self splitDataModelArray:channelModel newModels:arrays];
            if (mergedArrays) {
                arrays = mergedArrays;
            }
        }
        [self.allChannelsModelDic setObject:arrays forKey:channelModel.channel_id];
        NSArray *newArray = [NSArray arrayWithArray:arrays];
        successHandler(channelModel,newArray);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureHandler(task,error);
    }];
    return task;
}

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
 @return 拼接完成的数组
 */
- (NSMutableArray *)splitDataModelArray:(ChannelModel *)model newModels:(NSMutableArray *)array {
    // 二维数组
    NSMutableArray *originData = [self.allChannelsModelDic objectForKey:model.channel_id];
    if (originData) {
        if ([model.chnl_type isEqualToString:@"col"]) {
            for (NSMutableArray *subArray in array) {
                NSInteger index = [array indexOfObject:subArray];
                ;
                NSMutableArray *originSubData = originData[index];
                [originSubData addObjectsFromArray:subArray];
            }
        }else{
            // 1.去重
            NSMutableArray *disposedArray = [self disposeModels:array];
            // 2.拼接
            [originData addObjectsFromArray:disposedArray];
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
    if (self.tagedModels != nil) {
        for (SmallCellModel *model_new in models) {
            for (SmallCellModel *model_taged in self.tagedModels) {
                if ([model_new.article_id isEqualToString:model_taged.article_id]) {
                    NSInteger index = [models indexOfObject:model_new];
                    [models replaceObjectAtIndex:index withObject:model_taged];
                }
            }
        }
    }
    return models;
}

- (void)saveModelTag:(SmallCellModel *)model {
    if (model) {
        [self.tagedModels addObject:model];
    }
}
- (void)removeModelTag:(SmallCellModel *)model {
    if (model) {
        [self.tagedModels removeObject:model];
    }
}

- (void)freeData {
    self.channelModels = nil;
    self.rencommendModels = nil;
    self.allChannelsModelDic = nil;
    self.tagedModels = nil;
}
- (NSDictionary *)getAllChannelsModelDic {
    return self.allChannelsModelDic;
}

@end
