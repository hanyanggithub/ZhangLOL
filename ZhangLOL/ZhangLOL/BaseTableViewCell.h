//
//  BaseTableViewCell.h
//  ZhangLOL
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"

@interface BaseTableViewCell : UITableViewCell

- (NSString *)dealTimeWithDateString:(NSString *)time;
@property(nonatomic, strong)BaseModel *model;

@end
