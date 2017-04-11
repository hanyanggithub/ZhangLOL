//
//  UIView+Extension.h
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)CGFloat height;
@property(nonatomic, assign)CGFloat top;
@property(nonatomic, assign)CGFloat bottom;
@property(nonatomic, assign)CGFloat left;
@property(nonatomic, assign)CGFloat right;

- (UIViewController *)viewController;

- (void)removeSubviews;

@end
