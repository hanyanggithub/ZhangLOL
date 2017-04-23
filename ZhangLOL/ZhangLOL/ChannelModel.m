//
//  ChannelModel.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "ChannelModel.h"

@implementation ChannelModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super initWithDic:dic];
    if (self) {
        if (dic[@"id"]) {
           self.channel_id = dic[@"id"];
        }
    }
    return self;
}

@end
