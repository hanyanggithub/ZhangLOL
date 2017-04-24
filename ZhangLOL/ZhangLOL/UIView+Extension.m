//
//  UIView+Extension.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

@dynamic width,height,top,bottom,left,right;

- (UIViewController *)viewController {
    UIResponder *next = self;
    do {
        next = next.nextResponder;
    } while (![next isKindOfClass:[UIViewController class]]);
    return (UIViewController *)next;
}

- (CGFloat)width {
    return  self.frame.size.width;
}
- (CGFloat)height {
    return  self.frame.size.height;
}
- (CGFloat)top {
    return  self.frame.origin.y;
}
- (CGFloat)bottom {
    return  self.top + self.height;
}
- (CGFloat)left {
    return  self.frame.origin.x;
}
- (CGFloat)right {
    return  self.left + self.width;
}
- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.left, self.top, width, self.height);
}
- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.left, self.top, self.width, height);
}
- (void)setTop:(CGFloat)top {
    self.frame = CGRectMake(self.left, top, self.width, self.height);
}
- (void)setBottom:(CGFloat)bottom {
    self.frame = CGRectMake(self.left, bottom - self.height, self.width, self.height);
}
- (void)setLeft:(CGFloat)left {
    self.frame = CGRectMake(left, self.top, self.width, self.height);
}
- (void)setRight:(CGFloat)right {
    self.frame = CGRectMake(right - self.width, self.top, self.width, self.height);
}

- (void)removeSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end
