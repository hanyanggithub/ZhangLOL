//
//  RecommendPageControll.m
//  ZhangLOL
//
//  Created by mac on 17/4/4.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "RecommendPageControll.h"

@interface RecommendPageControll ()
@property(nonatomic, strong)NSMutableArray *imageViews;
@end

@implementation RecommendPageControll

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (void)setPages:(NSInteger)pages {
    if (_pages != pages) {
        [self removeSubviews];
        for (int i = 0; i < pages; i++) {
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(PAGR_CONTROLL_HEIGHT *i, 0, PAGR_CONTROLL_HEIGHT, PAGR_CONTROLL_HEIGHT)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_pagecontroller"] highlightedImage:[UIImage imageNamed:@"news_pagecontroller_hl"]];
            imageView.frame = CGRectMake(0, 0, PAGR_CONTROLL_HEIGHT, PAGR_CONTROLL_HEIGHT);
            [self addSubview:containerView];
            [containerView addSubview:imageView];
            [self.imageViews addObject:imageView];
        }
    }
}

- (void)setIndex:(NSInteger)index {
    
    if (index >= 0 && index < self.imageViews.count) {
        for (UIImageView *imageView in self.imageViews) {
            imageView.highlighted = NO;
        }
        UIImageView *imageView = self.imageViews[index];
        imageView.highlighted = YES;
        self.currentPage = index;
    }
}


@end
