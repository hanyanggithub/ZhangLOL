//
//  UIScrollView+Extension.m
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "UIScrollView+Extension.h"
#import "RefreshHeaderView.h"

@implementation UIScrollView (Extension)


- (void)removeFromSuperview {
    
    RefreshHeaderView *view = [self getRefreshHeaderView];
    if (view) {
        [self removeObserver:view forKeyPath:@"contentOffset"];
    }
    [super removeFromSuperview];
}

- (RefreshHeaderView *)getRefreshHeaderView {

    for (UIView *view in self.superview.subviews) {
        if ([view isKindOfClass:[RefreshHeaderView class]]) {
            return (RefreshHeaderView *)view;
        }
    }
    return nil;
}

@end
