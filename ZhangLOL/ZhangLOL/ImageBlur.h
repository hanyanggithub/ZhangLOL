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

@end
