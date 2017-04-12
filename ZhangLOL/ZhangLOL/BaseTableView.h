//
//  BaseTableView.h
//  ZhangLOL
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableView : UITableView
@property(nonatomic, assign)CGPoint priorPoint;
@property(nonatomic, strong)NSArray *models;
@property(nonatomic, strong)NSDictionary *dataInfo;
- (void)updateWithDataModels:(NSArray *)models dataInfo:(NSDictionary *)dataInfo;
@end
