//
//  DBManager.m
//  ZhangLOL
//
//  Created by mac on 17/4/22.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "DBManager.h"

@interface DBManager ()

@property(nonatomic, strong)FMDatabase *fmdb;

@end

NSString * const dbName = @"backups.sqlite";
static DBManager *singleton = nil;

@implementation DBManager

+ (DBManager *)singleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[DBManager alloc] init];
        NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",dbName];
        singleton.fmdb = [[FMDatabase alloc] initWithPath:filePath];
    });
    return singleton;
}
+ (NSString *)typeTransfer:(NSString *)ocType {
    ocType = [ocType lowercaseString];
    if ([ocType isEqualToString:@"int"] || [ocType isEqualToString:@"nsinteger"]) {
        return @"integer";
    }else if ([ocType isEqualToString:@"float"] || [ocType isEqualToString:@"double"] || [ocType isEqualToString:@"cgfloat"]){
        return @"real";
    }else if ([ocType isEqualToString:@"nsstring"]) {
        return @"text";
    }else if ([ocType isEqualToString:@"nsdata"]) {
        return @"blob";
    }else{
        return ocType;
    }
}


+ (void)createTableWithName:(NSString *)tableName
                  parameter:(NSDictionary *)parameter
                 primaryKey:(NSString *)primaryKey
              completeBlock:(completeBlock)block {
    DBManager *manager = [self singleton];
    NSString *parameterString = [NSString string];
    
    for (NSString *key in parameter) {
        NSString *value = [parameter valueForKey:key];
        if ([[self typeTransfer:key]  isEqualToString:[self typeTransfer:primaryKey]]) {
            parameterString = [parameterString stringByAppendingFormat:@"%@ %@ PRIMARY KEY,",key,[self typeTransfer:value]];
        }else{
            parameterString = [parameterString stringByAppendingFormat:@"%@ %@ ,",key,[self typeTransfer:value]];
        }
    }
    parameterString = [parameterString substringToIndex:parameterString.length - 1];
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@)",tableName,parameterString];
    
    if ([manager.fmdb open]) {
        if ([manager.fmdb executeUpdate:sql]) {
            block(YES,nil);
        }else{
            block(NO,nil);
        }
        [manager.fmdb close];
    }else{
        block(NO,nil);
    }
    
}

+ (BOOL)isExistsTableWithName:(NSString *)tableName {
    DBManager *manager = [self singleton];
    if ([manager.fmdb open]) {
        FMResultSet *rs = [manager.fmdb executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            [manager.fmdb close];
            if (0 == count) {
                return NO;
            }else{
                return YES;
            }
        }
        return NO;
    }else{
        return NO;
    }
}

+ (void)dropTableWithName:(NSString *)tableName completeBlock:(completeBlock)block {
    DBManager *manager = [self singleton];
    NSString *sql = [NSString stringWithFormat:@"drop table %@",tableName];
    if ([manager.fmdb open]) {
        if ([manager.fmdb executeUpdate:sql]) {
            block(YES,nil);
        }else{
            block(NO,nil);
        }
        [manager.fmdb close];
    }else{
        block(NO,nil);
    }
}
+ (void)insertDataInTableWithName:(NSString *)tableName
                        parameter:(NSDictionary *)parameter
                    completeBlock:(completeBlock)block {
    DBManager *manager = [self singleton];
    NSString *keyString = [NSString string];
    NSString *valueString = [NSString string];
    NSMutableArray *valuesArray = [NSMutableArray array];
    for (NSString *key in parameter) {
        keyString = [keyString stringByAppendingFormat:@"%@,",key];
        valueString = [valueString stringByAppendingFormat:@"%@,",@"?"];
        id value = [parameter valueForKey:key];
        [valuesArray addObject:value];
    }
    keyString = [keyString substringToIndex:keyString.length - 1];
    valueString = [valueString substringToIndex:valueString.length - 1];
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)",tableName,keyString,valueString];
    if ([manager.fmdb open]) {
        NSError *error = nil;
        if ([manager.fmdb executeUpdate:sql values:valuesArray error:&error]) {
            block(YES,nil);
        }else{
            block(NO,nil);
        }
        [manager.fmdb close];
    }else{
        block(NO,nil);
    }
}

+ (void)deleteDataInTableWithName:(NSString *)tableName whereParameter:(NSDictionary *)parameter completeBlock:(completeBlock)block {
    DBManager *manager = [self singleton];
    NSString *whereString = [NSString string];
    for (NSString *key in parameter) {
        id whereValue = [parameter valueForKey:key];
        if ([whereValue isKindOfClass:[NSString class]]) {
            whereValue = [NSString stringWithFormat:@"'%@'",whereValue];
        }
        whereString = [whereString stringByAppendingFormat:@"%@ = %@ and ",key,whereValue];
    }
    whereString = [whereString substringToIndex:whereString.length - 4];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@",tableName,whereString];
    if ([manager.fmdb open]) {
        if ([manager.fmdb executeUpdate:sql]) {
            block(YES,nil);
        }else{
            block(NO,nil);
        }
        [manager.fmdb close];
    }else{
        block(NO,nil);
    }
}

+ (void)selectDataInTableWithName:(NSString *)tableName completeBlock:(completeBlock)block {
    DBManager *manager = [self singleton];
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
    if ([manager.fmdb open]) {
        // 查询
        FMResultSet *set = [manager.fmdb executeQuery:sql];
        NSMutableArray *resultArray = [NSMutableArray array];
        while (set.next) {
            [resultArray addObject:set.resultDictionary];
        }
        if (resultArray != nil) {
            block(YES,resultArray);
        }else{
            block(YES,nil);
        }
        [manager.fmdb close];
    }else{
        block(NO,nil);
    }
}

@end
