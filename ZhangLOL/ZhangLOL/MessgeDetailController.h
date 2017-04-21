//
//  MessgeDetailController.h
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseViewController.h"

@class SmallCellModel;
@class RencommendModel;
@interface MessgeDetailController : BaseViewController

@property(nonatomic, strong)SmallCellModel *cellModel;
@property(nonatomic, strong)RencommendModel *vendorModel;
@end
