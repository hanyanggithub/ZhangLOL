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
#import <objc/runtime.h>

@interface MessageViewModel ()
@property(nonatomic, strong)NSMutableDictionary *fromDataBaseInfo;
@end

NSString * const channelTableName = @"channelTableName";
NSString * const rencommendTableName = @"rencommendTableName";

@implementation MessageViewModel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData) name:UIApplicationDidEnterBackgroundNotification object:nil];
        self.shouldShowNewMessageView = NO;
        self.newMessageCount = 0;
    }
    return self;
}
- (NSMutableDictionary *)fromDataBaseInfo {
    if (_fromDataBaseInfo == nil) {
        _fromDataBaseInfo = [NSMutableDictionary dictionary];
    }
    return _fromDataBaseInfo;
}
- (NSMutableDictionary *)getAllPropertyName:(Class)class {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propertyCount;
    objc_property_t *pArray = class_copyPropertyList(class, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = pArray[i];
        const char *property_name = property_getName(property);
        NSString *propertyName = [[NSString alloc] initWithUTF8String:property_name];
        [dic setObject:@"name" forKey:propertyName];
    }
    free(pArray);
    return dic;
}
- (BOOL)readDataFromDB {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",dbName];
    if (![fileManager fileExistsAtPath:filePath]) {
        return NO;
    }
    if ([DBManager isExistsTableWithName:channelTableName]) {
        [DBManager selectDataInTableWithName:channelTableName completeBlock:^(BOOL result, NSArray *resultData) {
            if (result && resultData.count > 0) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *dic in resultData) {
                    ChannelModel *model = [[ChannelModel alloc] initWithDic:dic];
                    [array addObject:model];
                }
                self.channelModels = array;
            }
        }];
    }
    
    if ([DBManager isExistsTableWithName:rencommendTableName]) {
        [DBManager selectDataInTableWithName:rencommendTableName completeBlock:^(BOOL result, NSArray *resultData) {
            if (result && resultData.count > 0) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *dic in resultData) {
                    RencommendModel *model = [[RencommendModel alloc] initWithDic:dic];
                    [array addObject:model];
                }
                self.rencommendModels = array;
            }
        }];
    }
    
    for (ChannelModel *channelModel in self.channelModels) {
        NSString *tableName = [NSString stringWithFormat:@"channelId%@_%@",channelModel.channel_id,[[Encrypt getMessageDigestMD5:channelModel.channel_id] substringToIndex:10]];
        if ([DBManager isExistsTableWithName:tableName]) {
            NSMutableArray *array = [NSMutableArray array];
            [DBManager selectDataInTableWithName:tableName completeBlock:^(BOOL result, NSArray *resultData) {
                if (result && resultData > 0) {
                    if ([channelModel.chnl_type isEqualToString:@"col"]) {
                        NSMutableArray *subArray1 = [NSMutableArray array];
                        NSMutableArray *subArray2 = [NSMutableArray array];
                        NSMutableArray *subArray3 = [NSMutableArray array];
                        for (NSDictionary *dic in resultData) {
                            SpecialModel *specialModel = [[SpecialModel alloc] initWithDic:dic];
                            if ([specialModel.type isEqualToString:@"0"]) {
                                [subArray1 addObject:specialModel];
                            }else if ([specialModel.type isEqualToString:@"1"]) {
                                [subArray2 addObject:specialModel];
                            }else if ([specialModel.type isEqualToString:@"2"]) {
                                [subArray3 addObject:specialModel];
                            }
                        }
                        [array addObject:subArray1];
                        [array addObject:subArray2];
                        [array addObject:subArray3];
                    }else{
                        for (NSDictionary *dic in resultData) {
                            SmallCellModel *smallCellModel = [[SmallCellModel alloc] initWithDic:dic];
                            [array addObject:smallCellModel];
                        }
                    }
                    [self.fromDataBaseInfo setObject:@"1" forKey:channelModel.channel_id];
                    [self.allChannelsModelDic setObject:array forKey:channelModel.channel_id];
                }
            }];
        }
    }
    return YES;
}
// 程序将要退出本地缓存部分数据
- (void)saveData {
    MYLog(@"%@",NSHomeDirectory());
    if (self.channelModels.count > 0) {
        if ([DBManager isExistsTableWithName:channelTableName]) {
          [DBManager dropTableWithName:channelTableName completeBlock:^(BOOL result, NSArray *resultData) {}];
        }
        ChannelModel *model = [self.channelModels firstObject];
        NSMutableDictionary *dic = [model transitionToDic];
        for (NSString *key in dic.allKeys) {
            [dic setObject:@"NSString" forKey:key];
        }
        __block BOOL exResult = NO;
        [DBManager createTableWithName:channelTableName parameter:dic primaryKey:@"channel_id" completeBlock:^(BOOL result, NSArray *resultData) {
            exResult = result;
        }];
        if (exResult) {
            for (ChannelModel *model in self.channelModels) {
                NSMutableDictionary *dic = [model transitionToDic];
                [DBManager insertDataInTableWithName:channelTableName parameter:dic completeBlock:^(BOOL result, NSArray *resultData) {
                }];
            }
        }
    }
    
    if (self.rencommendModels.count > 0) {
        if ([DBManager isExistsTableWithName:rencommendTableName]) {
            [DBManager dropTableWithName:rencommendTableName completeBlock:^(BOOL result, NSArray *resultData) {}];
        }
        RencommendModel *model = [self.rencommendModels firstObject];
        NSMutableDictionary *dic = [model transitionToDic];
        for (NSString *key in dic.allKeys) {
            [dic setObject:@"NSString" forKey:key];
        }
        __block BOOL exResult = NO;
        [DBManager createTableWithName:rencommendTableName parameter:dic primaryKey:@"content_id" completeBlock:^(BOOL result, NSArray *resultData) {
            exResult = result;
        }];
        if (exResult) {
            for (RencommendModel *model in self.rencommendModels) {
                NSMutableDictionary *dic = [model transitionToDic];
                [DBManager insertDataInTableWithName:rencommendTableName parameter:dic completeBlock:^(BOOL result, NSArray *resultData) {
                }];
            }
        }
    }
    
    if (self.allChannelsModelDic.allKeys.count > 0) {
        // 每频道保存20条数据
        for (NSString *key in self.allChannelsModelDic.allKeys) {
            NSString *tableName = [NSString stringWithFormat:@"channelId%@_%@",key,[[Encrypt getMessageDigestMD5:key] substringToIndex:10]];
            if ([DBManager isExistsTableWithName:tableName]) {
                [DBManager dropTableWithName:tableName completeBlock:^(BOOL result, NSArray *resultData) {}];
            }
            NSArray *everyChannalData = [self.allChannelsModelDic objectForKey:key];
            id data = [everyChannalData lastObject];
            if ([data isKindOfClass:[SmallCellModel class]]) {
                NSMutableDictionary *dic = [self getAllPropertyName:[SmallCellModel class]];
                for (NSString *key1 in dic.allKeys) {
                    [dic setObject:@"NSString" forKey:key1];
                }
                __block BOOL exResult = NO;
                [DBManager createTableWithName:tableName parameter:dic primaryKey:@"article_id" completeBlock:^(BOOL result, NSArray *resultData) {
                    exResult = result;
                }];
                if (exResult) {
                    for (int i = 0; i < 20; i++) {
                        SmallCellModel *smallCellModel = nil;
                        if (i < everyChannalData.count) {
                            smallCellModel = everyChannalData[i];
                            NSMutableDictionary *modelDic = [smallCellModel transitionToDic];
                            [DBManager insertDataInTableWithName:tableName parameter:modelDic completeBlock:^(BOOL result, NSArray *resultData) {
                            }];
                        }
                    }
                }
            }else if ([data isKindOfClass:[NSArray class]]) {
                NSArray<NSArray *> *array = everyChannalData;
                SpecialModel *specialModel = (SpecialModel *)[[array lastObject] firstObject];
                NSMutableDictionary *dic = [specialModel transitionToDic];
                for (NSString *key1 in dic.allKeys) {
                    [dic setObject:@"NSString" forKey:key1];
                }
                __block BOOL exResult = NO;
                [DBManager createTableWithName:tableName parameter:dic primaryKey:@"col_id" completeBlock:^(BOOL result, NSArray *resultData) {
                    exResult = result;
                }];
                if (exResult) {
                    for (NSArray *subArray in array) {
                        for (int i = 0; i < 20; i++) {
                            SpecialModel *specialModel = nil;
                            if (i < subArray.count) {
                                specialModel = subArray[i];
                                NSMutableDictionary *modelDic = [specialModel transitionToDic];
                                [DBManager insertDataInTableWithName:tableName parameter:modelDic completeBlock:^(BOOL result, NSArray *resultData) {
                                }];
                            }
                        }
                    }
                }
            }
        }
    }
}

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
                                              success:(void (^)(ChannelModel *channelModel, NSArray *models))successHandler
                                              failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failureHandler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *url = nil;
    if (page.integerValue != 0) {
        // 判断是否可以加载更多
        NSMutableArray *originData = [self.allChannelsModelDic objectForKey:channelModel.channel_id];
        if (originData) {
            if ([channelModel.chnl_type isEqualToString:@"col"]) {
                NSArray *any = [originData lastObject];
                SpecialModel *specialModel = [any lastObject];
                if ([specialModel.has_next isEqualToString:@"0"]) {
                    successHandler(channelModel,nil);
                    return nil;
                }
            }else{
                SmallCellModel *smallCellModel = [originData lastObject];
                if ([smallCellModel.has_next isEqualToString:@"0"]) {
                    successHandler(channelModel,nil);
                    return nil;
                }
            }
        }
    }
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
        // 处理数据
        NSMutableArray *arrays = [self dealDataWithResponseObject:responseObject channelModel:channelModel];
        // 数据合并处理
        BOOL result = [self mergeModelDataArrayWithChannelModel:channelModel newModels:arrays page:page.intValue];
        if (!result) {
            // 首次数据备份
            [self.allChannelsModelDic setObject:arrays forKey:channelModel.channel_id];
        }
        // 返回上层
        successHandler(channelModel,[self.allChannelsModelDic objectForKey:channelModel.channel_id]);
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
        NSArray *keys = @[@"recommend_list",@"book_list",@"unbook_list"];
        NSString *hasNext = responseObject[@"hasnext"];
        for (int i = 0; i < 3; i++) {
            NSString *key = keys[i];
            NSMutableArray *data = responseObject[key];
            NSMutableArray *save = [NSMutableArray array];
            for (NSDictionary *dic in data) {
                SpecialModel *specialModel = [[SpecialModel alloc] initWithDic:dic];
                specialModel.type = [NSString stringWithFormat:@"%d",i];
                specialModel.has_next = hasNext;
                [save addObject:specialModel];
            }
            [arrays addObject:save];
        }
    }else{
        // 其他类型
        NSArray *array = responseObject[@"list"];
        NSString *next = responseObject[@"next"];
        if (array.count == 0) {
            NSMutableArray *originData = [self.allChannelsModelDic objectForKey:model.channel_id];
            if (originData) {
                SmallCellModel *smallCellModel = [originData lastObject];
                smallCellModel.has_next = @"0";
            }
        }
        for (NSDictionary *dic in array) {
            SmallCellModel *smallModel = [[SmallCellModel alloc] initWithDic:dic];
            if ([next isEqualToString:@"True"]) {
                smallModel.has_next = @"1";
            }else{
                smallModel.has_next = @"0";
            }
            [arrays addObject:smallModel];
        }
    }
    return arrays;
}


- (BOOL)mergeModelDataArrayWithChannelModel:(ChannelModel *)model newModels:(NSMutableArray *)array page:(int)page {
    
    BOOL result = NO;
    
    // 获取原始数据
    NSMutableArray *originData = [self.allChannelsModelDic objectForKey:model.channel_id];
    if (originData) {
        // 判断是否从本地数据库中获取到的原始数据
        NSString *info = [self.fromDataBaseInfo objectForKey:model.channel_id];
        
        if ([info isEqualToString:@"1"]) {
            [self.fromDataBaseInfo setObject:@"0" forKey:model.channel_id];
            // 如果是最新频道计算有几条新的消息
            if ([model.channel_id isEqualToString:@"12"]) {
                SmallCellModel *orgNewetModel = [originData firstObject];
                for (NSInteger i = array.count -1; i < array.count; i--) {
                    SmallCellModel *everyNewModel = array[i];
                    // 比较顺序
                    int oldT = [self getTimeIntervalSinceNow:orgNewetModel.publication_date];
                    int newT = [self getTimeIntervalSinceNow:everyNewModel.publication_date];
                    if (newT < oldT) {
                        self.shouldShowNewMessageView = YES;
                        self.newMessageCount++;
                    }
                }
            }
            
        }else{
            result = YES;
            if (page != 0) {
                // 加载更多数据
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
                // 刷新或者是首次请求
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
                    // 计算新数据个数
                    SmallCellModel *orgNewetModel = [originData firstObject];
                    for (NSInteger i = array.count -1; i < array.count; i--) {
                        SmallCellModel *everyNewModel = array[i];
                        // 比较顺序
                        int oldT = [self getTimeIntervalSinceNow:orgNewetModel.publication_date];
                        int newT = [self getTimeIntervalSinceNow:everyNewModel.publication_date];
                        if (newT < oldT) {
                            if ([model.name isEqualToString:@"最新"]) {
                                self.shouldShowNewMessageView = YES;
                                self.newMessageCount++;
                            }
                        }
                        [originData replaceObjectAtIndex:i withObject:everyNewModel];
                    }
                    // 标记本地点击过的cellModel
                    originData = [self disposeModels:originData];
                    [self.allChannelsModelDic setObject:originData forKey:model.channel_id];
                }
                
            }

        }
        
    }
    return result;
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
