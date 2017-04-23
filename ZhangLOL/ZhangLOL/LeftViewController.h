//
//  LeftViewController.h
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseViewController.h"

@protocol LeftViewControllerDelegate <NSObject>

- (void)leftViewControllerLoginBtnClicked;

@end

@interface LeftViewController : BaseViewController
@property(nonatomic, weak)id<LeftViewControllerDelegate> delegate;
@property(nonatomic, strong)NSDictionary *userInfo;
@end
