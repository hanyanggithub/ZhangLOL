//
//  NewestBaseCell.h
//  ZhangLOL
//
//  Created by mac on 17/4/18.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface NewestBaseCell : BaseTableViewCell
@property(nonatomic, strong)UIView *bigContainerView; // 大容器视图包含所有的子控件
@property(nonatomic, strong)UILabel *title;           // 标题
@property(nonatomic, strong)UILabel *detail;          // 内容
@property(nonatomic, strong)UILabel *time;            // 发布时间
@property(nonatomic, strong)UILabel *readed;          // 阅读量
@property(nonatomic, strong)UILabel *typeLabel;       // 类型
- (void)setNewstypeWithNewsTypeId:(NSString *)str;   // 设置类型标签
@end
