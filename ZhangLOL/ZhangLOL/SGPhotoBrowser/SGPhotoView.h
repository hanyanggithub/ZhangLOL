//
//  SGPhotoView.h
//  SGSecurityAlbum
//
//  Created by soulghost on 10/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SGPhotoViewTapHandlerBlcok)(void);

@interface SGPhotoView : UIScrollView

@property (nonatomic, readonly) NSInteger currentIndex;         // 当前索引位置
@property (nonatomic, readonly) UIImage *currentImage;      // 当前显示的image
// 点击事件的回调
- (void)setSingleTapHandlerBlock:(SGPhotoViewTapHandlerBlcok)handler;
// 显示图片
- (void)showImageWithUrls:(NSArray *)urls;

@end
