//
//  LeftViewController.h
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeftViewController;

@protocol LeftViewControllerDelegate <NSObject>

- (void)leftViewControllerLoginBtnClicked;

@end

@interface LeftViewController : UIViewController
@property(nonatomic, weak)id<LeftViewControllerDelegate> delegate;
@property(nonatomic, strong)NSDictionary *userInfo;
@end
