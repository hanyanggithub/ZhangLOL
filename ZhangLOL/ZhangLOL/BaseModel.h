//
//  BaseModel.h
//  ZhangLOL
//
//  Created by mac on 17/4/4.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject
@property(nonatomic, assign)BOOL isRead;
- (instancetype)initWithDic:(NSDictionary *)dic;

@end
