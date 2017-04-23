//
//  DBManager.h
//  ZhangLOL
//
//  Created by mac on 17/4/22.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completeBlock)(BOOL result,NSArray *resultData);

@interface DBManager : NSObject

+ (void)createTableWithName:(NSString *)tableName
                  parameter:(NSDictionary *)parameter
                 primaryKey:(NSString *)primaryKey
              completeBlock:(completeBlock)block;

+ (BOOL)isExistsTableWithName:(NSString *)tableName;


+ (void)dropTableWithName:(NSString *)tableName completeBlock:(completeBlock)block;


+ (void)insertDataInTableWithName:(NSString *)tableName
                        parameter:(NSDictionary *)parameter
                    completeBlock:(completeBlock)block;

+ (void)deleteDataInTableWithName:(NSString *)tableName
                   whereParameter:(NSDictionary *)parameter
                    completeBlock:(completeBlock)block;

+ (void)selectDataInTableWithName:(NSString *)tableName completeBlock:(completeBlock)block;

@end
