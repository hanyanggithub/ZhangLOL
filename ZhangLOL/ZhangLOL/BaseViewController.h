//
//  BaseViewController.h
//  ZhangLOL
//
//  Created by mac on 17/4/15.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property(nonatomic, strong)UINavigationBar *customNaviBar;
@property(nonatomic, strong)UINavigationItem *customNaviItem;
- (void)pop;
@end
