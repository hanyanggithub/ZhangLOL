//
//  RecommendView.m
//  ZhangLOL
//
//  Created by mac on 17/4/4.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "RecommendView.h"
#import "RecommendPageControll.h"
#import "RencommendModel.h"
#import "MessgeDetailController.h"

@interface RecommendView ()<UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)RecommendPageControll *pageControll;
@property(nonatomic, strong)NSArray<RencommendModel *> *models;
@property(nonatomic, strong)NSMutableArray<UIImageView *> *imagesViews;
@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)NSInteger currentIndex;
@property(nonatomic, assign)BOOL isScrolling;

@end

@implementation RecommendView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.bounces = NO;
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollView];
    }
    return self;
}
- (NSMutableArray *)imagesViews {
    if (_imagesViews == nil) {
        _imagesViews = [NSMutableArray array];
    }
    return _imagesViews;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:weakSelf selector:@selector(timerAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] run];
        });
    }
    return _timer;
}

- (void)changeScrollViewContentWithModels:(NSArray *)models {
    
    if (self.models == nil) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width * (models.count + 2), self.scrollView.height);
        for (int i = 0; i < models.count + 2; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.width * i, 0, self.scrollView.width, self.scrollView.height)];
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
            [imageView addGestureRecognizer:tap];
            [self.scrollView addSubview:imageView];
            [self.imagesViews addObject:imageView];
            
        }
        [self startAutoScrolling];
    }else{
        [self stopAutoScrolling];
        NSInteger count = self.models.count - models.count;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width - self.scrollView.width * count, self.scrollView.height);
        for (int i = 0; i < ABS(count); i++) {
            if (count > 0) {
                // 移除
                UIImageView *subview = self.imagesViews[models.count + i];
                [subview removeSubviews];
                [self.imagesViews removeObject:subview];
                
            }else{
                // 添加
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.width * (self.models.count + i), 0, self.scrollView.width, self.scrollView.height)];
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
                [imageView addGestureRecognizer:tap];
                [self.scrollView addSubview:imageView];
                [self.imagesViews addObject:imageView];
            }
            
        }
        [self startAutoScrolling];
    }
    if (self.pageControll != nil) {
        [self.pageControll removeSubviews];
        self.pageControll = nil;
    }
    
    self.pageControll = [[RecommendPageControll alloc] initWithFrame:CGRectZero];
    [self addSubview:self.pageControll];
    self.pageControll.frame = CGRectMake(0, 0, models.count * PAGR_CONTROLL_HEIGHT, PAGR_CONTROLL_HEIGHT);
    self.pageControll.center = CGPointMake(self.center.x, 0);
    self.pageControll.bottom = self.bottom;
    [self.pageControll setPages:models.count];
    
}


- (void)updateWithModels:(NSArray *)models {
    
    if (self.models.count != models.count) {
        [self changeScrollViewContentWithModels:models];
    }

    // 轮播实现方式有很多，这里采用n+2基于scrollView的实现方式
    NSMutableArray *array = [NSMutableArray array];
    id first = [models firstObject];
    id last = [models lastObject];
    [array addObject:last];
    [array addObjectsFromArray:models];
    [array addObject:first];
    for (int i = 0; i < array.count; i++) {
        RencommendModel *model = array[i];
        UIImageView *imageView = self.imagesViews[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.image_url_big] placeholderImage:[UIImage imageNamed:@"hero_detail_head_default"] options:SDWebImageRetryFailed|SDWebImageProgressiveDownload];
    }
    self.scrollView.contentOffset = CGPointMake(self.scrollView.width, 0);
    [self.pageControll setIndex:0];
    self.currentIndex = 0;
    self.models = models;
}

- (UIImage *)getCurrentShowImage {
    RencommendModel *model = self.models[self.currentIndex];
    UIImage *image = nil;
    image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:model.image_url_big];
    if (image == nil) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.image_url_big];
    }
    image = [ImageBlur reSizeImage:image toSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH * 0.5)];
    image = [ImageBlur clipImageWithImage:image inRect:CGRectMake(0, image.size.height - NAVI_STATUS_BAR_HEIGHT, image.size.width, NAVI_STATUS_BAR_HEIGHT)];
    image = [ImageBlur gaussBlurWithLevel:1.0 image:image];
    return image;
}
- (void)tapImageViewAction:(UITapGestureRecognizer *)tap {
    UIImageView *imageView = (UIImageView *)tap.view;
    NSInteger imageViewIndex = [self.imagesViews indexOfObject:imageView];
    RencommendModel *model = nil;
    if (imageViewIndex == 0) {
        model = [self.models lastObject];
    }else if (imageViewIndex == self.imagesViews.count - 1) {
        model = [self.models firstObject];
    }else{
        model = self.models[imageViewIndex - 1];
    }
    MessgeDetailController *detail = [MessgeDetailController new];
    detail.vendorModel = model;
    [self.viewController.navigationController pushViewController:detail animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        [self stopAutoScrolling];
    }
    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.width;
    CGFloat x = self.scrollView.contentOffset.x - page * self.scrollView.width;
    if (x > self.scrollView.width * 0.5) {// 显示后一页
        if (page != 0 && page != self.models.count + 1) {
            self.currentIndex = page;
        }
        if (page == self.models.count) {
            self.currentIndex = 0;
        }
        if (page == 0) {
            self.currentIndex = 0;
        }
    }else{// 显示前一页
        if (page != 0 && page != self.models.count + 1) {
            self.currentIndex = page - 1;
        }
        if (page == self.models.count + 1) {
            self.currentIndex = page - 1;
        }
        if (page == 0) {
            self.currentIndex = self.models.count - 1;
        }
    }
    [self.pageControll setIndex:self.currentIndex];
    
    // 最大位置
    if (scrollView.contentOffset.x == scrollView.width * (self.imagesViews.count - 1)) {
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
    }
    // 最小位置
    if (scrollView.contentOffset.x == 0) {
        scrollView.contentOffset = CGPointMake(scrollView.width * (self.imagesViews.count - 2), 0);
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startAutoScrolling];
}

- (void)timerAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.window) {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.scrollView.width, 0) animated:YES];
        }
    });
}

- (void)startAutoScrolling {
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
}
- (void)stopAutoScrolling {
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
