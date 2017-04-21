//
//  RefreshHeaderView.h
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,RefreshHeaderViewStatus) {
    RefreshHeaderViewStatusWaitUserSlideDown,   // 等待用户下滑的状态
    RefreshHeaderViewStatusUserSlidingDown,     // 用户正在下滑的状态
    RefreshHeaderViewStatusWaitUserLoosen,      // 等待用户松手的状态
    RefreshHeaderViewStatusRefreshing           // 刷新状态
};


typedef NS_ENUM(NSInteger,RefreshHeaderViewLocation) {
    RefreshHeaderViewLocationBottomEqualToScrollViewTop, // 底部和ScrollView顶部平行
    RefreshHeaderViewLocationTopEqualToScrollViewTop    // 顶部和ScrollView顶部平行
    
};

@interface RefreshHeaderView : UIView

- (instancetype)initWithScrollView:(UIScrollView *)scrollView location:(RefreshHeaderViewLocation)location;
- (RefreshHeaderViewStatus)currentStatus;
- (void)refreshHeaderViewStatusChangedBlock:(void(^)(RefreshHeaderViewStatus status))block;
- (void)stopRefreshing;

@end
