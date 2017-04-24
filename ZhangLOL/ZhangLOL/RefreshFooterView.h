//
//  RefreshFooterView.h
//  ZhangLOL
//
//  Created by mac on 17/4/21.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,RefreshFooterViewStatus) {
    RefreshFooterViewStatusWaitRefreshing,      // 等待刷新状态
    RefreshFooterViewStatusWaitUserLoosen,      // 等待用户松手的状态
    RefreshFooterViewStatusRefreshing           // 刷新状态
};

@interface RefreshFooterView : UIView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
- (RefreshFooterViewStatus)currentStatus;
- (void)refreshFooterViewStatusChangedBlock:(void(^)(RefreshFooterViewStatus status))block;
- (void)startRefreshing;
- (void)stopRefreshing;
@end
