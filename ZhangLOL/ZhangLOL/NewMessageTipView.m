//
//  NewMessageTipView.m
//  ZhangLOL
//
//  Created by mac on 17/4/24.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "NewMessageTipView.h"

#define TIP_VIEW_WIDTH (SCREEN_WIDTH * 0.5)


@implementation NewMessageTipView

+ (void)showMessage:(NSString *)message {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((window.frame.size.width - TIP_VIEW_WIDTH) * 0.5, -40, TIP_VIEW_WIDTH, 40)];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = MAIN_COLOR;
    label.alpha = 0.9;
    [window addSubview:label];
    
    [UIView animateWithDuration:0.35 animations:^{
        label.frame = CGRectMake((window.frame.size.width - TIP_VIEW_WIDTH) * 0.5, 20, TIP_VIEW_WIDTH, 40);
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.35 animations:^{
                label.alpha = 0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        });
    }];
}

@end
