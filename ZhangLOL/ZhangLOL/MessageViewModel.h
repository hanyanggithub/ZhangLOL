//
//  MessageViewModel.h
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChannelModel;
@class SmallCellModel;

@interface MessageViewModel : NSObject
@property(nonatomic, strong)NSMutableArray *channelModels;
@property(nonatomic, strong)NSMutableArray *rencommendModels;
@property(nonatomic, strong)NSMutableDictionary *allChannelsModelDic;
@property(nonatomic, strong)NSMutableArray<SmallCellModel *> *tagedModels; // 存储当前阅读过的消息模型

/**
 请求频道栏数据
 */
- (void)requestChannelData:(NSString *)url
                   success:(void (^)(NSURLSessionDataTask *task, NSArray *models))successHandler
                   failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler;


/**
 请求banner数据
 */
- (void)requestRecommendData:(NSString *)url
                     success:(void (^)(NSURLSessionDataTask *task, NSArray *models))successHandler
                     failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler;


/**
 请求频道对应的单页数据

 @param merge 是否和已有的模型数组合并
 */
- (NSURLSessionDataTask *)requestDataWithChannelModel:(ChannelModel *)channelModel
                                                 page:(NSString *)page
                                       automaticMerge:(BOOL)merge
                                              success:(void (^)(ChannelModel *channelModel, NSArray *models))successHandler
                                              failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler;

/**
 保存已经获取到的数据模型这些模型的已读状态已经被修改

 @param model 状态修改后的模型
 */
- (void)saveModelTag:(SmallCellModel *)model;


/**
 releaseData
 */
- (void)freeData;


/**
 获取所有模型

 @return 模型数组字典
 */
- (NSDictionary *)getAllChannelsModelDic;

@end
