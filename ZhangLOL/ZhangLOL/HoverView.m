//
//  HoverView.m
//  ZhangLOL
//
//  Created by mac on 17/4/3.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "HoverView.h"

@interface HoverView ()

@property(nonatomic, strong)NSMutableArray<UIButton *> *buttons;
@property(nonatomic, strong)NSArray *models;

@end

@implementation HoverView


- (void)updateWithModels:(NSArray *)models {
    self.models = models;
    if (models.count != self.buttons.count) {
        [self removeSubviews];
        [self.buttons removeAllObjects];
        CGFloat buttonWidth = SCREEN_WIDTH / models.count;
        for (int i = 0; i< models.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, self.height);
//            [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor redColor];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.buttons addObject:button];
        }
    }
}
- (void)buttonClicked:(UIButton *)button {
    NSInteger index = [self.buttons indexOfObject:button];
    id model = self.models[index];
    NSLog(@"%@",model);
}


@end
