//
//  BaseTableView.m
//  ZhangLOL
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseTableView.h"

@interface BaseTableView()<UIGestureRecognizerDelegate>

@end

@implementation BaseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)updateWithDataModels:(NSArray *)models dataInfo:(NSDictionary *)dataInfo {
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([otherGestureRecognizer.view isMemberOfClass:NSClassFromString(@"MessageScrollView")] || [otherGestureRecognizer isMemberOfClass:NSClassFromString(@"SWRevealViewControllerPanGestureRecognizer")]) {
        return NO;
    }else{
        id systemTarget = otherGestureRecognizer.view.viewController.navigationController.interactivePopGestureRecognizer.delegate;
        if (![otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] && [systemTarget isKindOfClass:NSClassFromString(@"_UINavigationInteractiveTransition")]) {
            return NO;
        }
    }
    
    return YES;
}

@end
