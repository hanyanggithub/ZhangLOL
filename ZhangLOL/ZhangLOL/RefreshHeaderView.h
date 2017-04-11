//
//  RefreshHeaderView.h
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,RefreshHeaderViewStatus) {
    RefreshHeaderViewStatusWaitScroll,
    RefreshHeaderViewStatusScrolling,
    RefreshHeaderViewStatusWaitLoosen,
    RefreshHeaderViewStatusRefreshing
};

@interface RefreshHeaderView : UIView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
- (RefreshHeaderViewStatus)currentStatus;
- (void)refreshHeaderViewStatusChangedBlock:(void(^)(RefreshHeaderViewStatus status))block;
- (void)stopRefreshing;

@end
