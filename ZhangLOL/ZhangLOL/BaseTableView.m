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
    }
    return self;
}

- (void)updateWithChannelModels:(NSArray *)models {
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
