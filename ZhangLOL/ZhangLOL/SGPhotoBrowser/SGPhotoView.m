//
//  SGPhotoView.m
//  SGSecurityAlbum
//
//  Created by soulghost on 10/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGPhotoView.h"
#import "SGZoomingImageView.h"
#import "SGPhotoViewController.h"


@interface SGPhotoView () <UIScrollViewDelegate>

@property (nonatomic, copy) SGPhotoViewTapHandlerBlcok singleTapHandler;
@property (nonatomic, strong) NSArray<SGZoomingImageView *> *imageViews;
@property (nonatomic, strong) NSArray *imageUrls;

@end

@implementation SGPhotoView

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
    }
}
- (void)setCurrentImage:(UIImage *)currentImage {
    if (_currentImage != currentImage) {
        _currentImage = currentImage;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.pagingEnabled = YES;
        self.delegate = self;
        self.currentIndex = 0;
    }
    return self;
}
- (void)showImageWithUrls:(NSArray *)urls {
    self.imageUrls = urls;
    NSMutableArray *imageViews = [NSMutableArray array];
    // 创建
    self.contentSize = CGSizeMake(self.imageUrls.count * self.width, 0);
    
    __weak typeof(self) weakSelf = self;
    for (NSUInteger i = 0; i < self.imageUrls.count; i++) {
        NSURL *url = self.imageUrls[i];
        // scrollView
        SGZoomingImageView *imageView = [[SGZoomingImageView alloc] initWithFrame:CGRectMake(i * self.width, 0, self.width, self.height)];
        [imageView setSingleTapHandler:^{
            if (weakSelf.singleTapHandler) {
                weakSelf.singleTapHandler();
            }
        }];
        // scrollView.imageView
        [imageView.innerImageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            // 加载完成,调整大小
            [imageView scaleToFitAnimated:NO];
            if (i == 0) {
                weakSelf.currentImage = image;
            }
        }];
        
        [self addSubview:imageView];
        [imageViews addObject:imageView];
    }
    self.imageViews = imageViews;
    [self updateNavBarTitleWithIndex:self.currentIndex];
}

- (void)updateNavBarTitleWithIndex:(NSInteger)index {
    
    BaseViewController *selfVc = (BaseViewController *)[self viewController];
    selfVc.customNaviItem.title = [NSString stringWithFormat:@"%@/%@",@(self.currentIndex + 1),@(self.imageUrls.count)];
}

- (void)setSingleTapHandlerBlock:(SGPhotoViewTapHandlerBlcok)handler {
    self.singleTapHandler = handler;
}

#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = offsetX / self.width;
    if (self.currentIndex != index) {
        // 重置上一张图片为初始状态
        SGZoomingImageView *imageView = self.imageViews[self.currentIndex];
        [imageView scaleToFitAnimated:NO];
        // 设置新索引位置
        self.currentIndex = index;
        self.currentImage = self.imageViews[self.currentIndex].innerImageView.image;
        // 设置导航显示的页数
        [self updateNavBarTitleWithIndex:self.currentIndex];

    }

}


@end
