//
//  ImageBlur.h
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageBlur : NSObject
// 从图片像素点获取颜色
+ (UIColor *)getImagePixelColorWithPoint:(UIImage *)image point:(CGPoint)point;
// 高斯虚化
+ (UIImage *)gaussBlurWithLevel:(CGFloat)blurLevel image:(UIImage *)image;
// 缩放图片
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
// 裁切图片
+ (UIImage *)clipImageWithImage:(UIImage*)image inRect:(CGRect)rect;

@end
