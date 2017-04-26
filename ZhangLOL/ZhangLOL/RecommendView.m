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
@property(nonatomic, assign)BOOL isAutoScrolling;

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
        // 多线程创建定时器
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] run];
        });
    }
    return _timer;
}

// 轮播实现方式有很多，这里采用n+2基于scrollView的实现方式
- (void)updateWithModels:(NSArray *)models {
    if (models == nil || models.count == 0) {
        return;
    }
    // 关闭自动轮播
    [self stopAutoScrolling];
    if (self.models == nil) {
        // 首次创建子视图
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width * (models.count + 2), self.scrollView.height);
        for (int i = 0; i < models.count + 2; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.width * i, 0, self.scrollView.width, self.scrollView.height)];
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
            [imageView addGestureRecognizer:tap];
            [self.scrollView addSubview:imageView];
            [self.imagesViews addObject:imageView];
            
        }
        self.pageControll = [[RecommendPageControll alloc] initWithFrame:CGRectZero];
        self.pageControll.frame = CGRectMake(0, 0, models.count * PAGR_CONTROLL_HEIGHT, PAGR_CONTROLL_HEIGHT);
        self.pageControll.center = CGPointMake(self.center.x, 0);
        self.pageControll.bottom = self.bottom - 5;
        [self addSubview:self.pageControll];

    }else{
        // 更新数量
        NSInteger count = models.count - self.models.count;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width + self.scrollView.width * count, self.scrollView.height);
        for (int i = 0; i < ABS(count); i++) {
            if (count > 0) {
                // 添加
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.width * (self.models.count + 2 + i), 0, self.scrollView.width, self.scrollView.height)];
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
                [imageView addGestureRecognizer:tap];
                [self.scrollView addSubview:imageView];
                [self.imagesViews addObject:imageView];
                
            }else if (count < 0){
                // 移除
                UIImageView *subview = self.imagesViews[models.count + 2 + i];
                [subview removeFromSuperview];
                [self.imagesViews removeObject:subview];
            }
            
        }
    }
    // 设置页数
    self.pageControll.pages = models.count;

    // 赋值数据
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
    
    // 设置成初始状态
    self.scrollView.contentOffset = CGPointMake(self.scrollView.width, 0);
    self.pageControll.currentIndex = 0;
    self.currentIndex = 0;
    
    // 保存模型数组
    self.models = models;
    
    // 开启自动轮播
    [self startAutoScrolling];
}

- (UIImage *)getCurrentShowImage {
    UIImageView *imageView = self.imagesViews[self.currentIndex + 1];
    RencommendModel *model = self.models[self.currentIndex];
    UIImage *image = imageView.image;
    if (image == nil) {
        image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:model.image_url_big];
    }
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
    // 用户正在交互中
    if (scrollView.panGestureRecognizer.state != UIGestureRecognizerStatePossible) {
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
    // 设置PageCotroll的显示页
    self.pageControll.currentIndex = self.currentIndex;
    
    // 最大位置时滑到scrollView.width
    if (scrollView.contentOffset.x >= scrollView.width * (self.imagesViews.count - 1)) {
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
    }
    // 最小位置滑动scrollView.width * (self.imagesViews.count - 2)
    if (scrollView.contentOffset.x <= 0) {
        scrollView.contentOffset = CGPointMake(scrollView.width * (self.imagesViews.count - 2), 0);
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 开启自动滑动
    [self startAutoScrolling];
}

- (void)timerAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.superview) {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.scrollView.width, 0) animated:YES];
        }
    });
}

- (void)startAutoScrolling {
    if (!self.isAutoScrolling) {
        self.isAutoScrolling = YES;
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
    }
}
- (void)stopAutoScrolling {
    if (self.isAutoScrolling) {
        self.isAutoScrolling = NO;
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
