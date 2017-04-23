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

@property(nonatomic, assign)BOOL readFromDB;                                // 标识启动数据是否从数据库中读取
@property(nonatomic, strong)NSMutableArray *channelModels;                  // 频道模型
@property(nonatomic, strong)NSMutableArray *rencommendModels;               // 轮播模型
@property(nonatomic, strong)NSMutableDictionary *allChannelsModelDic;       // 所有频道单元格模型
@property(nonatomic, strong)NSMutableArray<SmallCellModel *> *tagedModels;  // 存储当前阅读过的单元格模型

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
 */
- (NSURLSessionDataTask *)requestDataWithChannelModel:(ChannelModel *)channelModel
                                                 page:(NSString *)page
                                              success:(void (^)(ChannelModel *channelModel, NSArray *models))successHandler
                                              failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler;

/**
 保存已经获取到的数据模型这些模型的已读状态已经被修改

 @param model 状态修改后的模型
 */
- (void)saveModelTag:(SmallCellModel *)model;

// 读取本地数据
- (void)readDataFromDB;

@end
