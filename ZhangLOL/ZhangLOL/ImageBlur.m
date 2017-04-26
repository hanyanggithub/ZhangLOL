//
//  ImageBlur.m
//  ZhangLOL
//
//  Created by mac on 17/4/9.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <ImageIO/ImageIO.h>

@implementation ImageBlur

+ (UIColor *)getImagePixelColorWithPoint:(UIImage *)image point:(CGPoint)point  {

    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    
    CGContextRef context = CGBitmapContextCreate(pixelData,1,1,bitsPerComponent,bytesPerRow,colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIImage *)gaussBlurWithLevel:(CGFloat)blurLevel image:(UIImage *)image {
    if (blurLevel < 0.f || blurLevel > 1.f) {
        blurLevel = 0.5f;
    }
    int boxSize = (int)(blurLevel * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGRect imageRect = { CGPointZero, image.size};
    UIImage *effectImage = image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 0.0);
    CGContextRef effectInContext = UIGraphicsGetCurrentContext();
    [image drawInRect:imageRect];
    
    vImage_Buffer effectInBuffer;
    effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
    effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
    effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
    effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
    
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 0.0);
    CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
    
    vImage_Buffer effectOutBuffer;
    effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
    effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
    effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
    effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
    
    vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, boxSize, boxSize, 0, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, boxSize, boxSize, 0, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, boxSize, boxSize, 0, kvImageEdgeExtend);
//    vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, boxSize, boxSize, 0, kvImageEdgeExtend);
    
    effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsEndImageContext();
    
    return effectImage;
}

+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize {
    
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
    
}


+ (UIImage *)clipImageWithImage:(UIImage*)image inRect:(CGRect)rect {
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, imageRef);
    UIImage *clipImage = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    UIGraphicsEndImageContext();
    return clipImage;
    
}

+ (void)downloadLaunchImageIsForce:(BOOL)force {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *launchImagePath = [NSString stringWithFormat:@"%@/Documents/launch.png",NSHomeDirectory()];
    BOOL launchImageExist = [fileManager fileExistsAtPath:launchImagePath];
    if (launchImageExist) {
        if (force) {
            NSError *error = nil;
            [fileManager removeItemAtPath:launchImagePath error:&error];
            if (error == nil) {
                [self requestLaunchImage];
            }
        }
    }else{
        [self requestLaunchImage];
    }
    
    
    NSString *loginImagePath = [NSString stringWithFormat:@"%@/Documents/login.png",NSHomeDirectory()];
    BOOL loginImageExist = [fileManager fileExistsAtPath:loginImagePath];
    if (loginImageExist) {
        if (force) {
            NSError *error = nil;
            [fileManager removeItemAtPath:loginImagePath error:&error];
            if (error == nil) {
                [self requestLoginImage];
            }
        }
    }else{
        [self requestLoginImage];
    }
}

+ (void)requestLaunchImage {
    // 请求开机图
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:LAUNCH_IMAGE_URL]];
    [ZhangLOLNetwork downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [NSString stringWithFormat:@"file://%@/Documents/launch.png",NSHomeDirectory()];
        NSURL *url = [NSURL URLWithString:path];
        return url;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
}
+ (void)requestLoginImage {
    // 请求登录bg
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:LOGIN_IMAGE_URL]];
    [ZhangLOLNetwork downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [NSString stringWithFormat:@"file://%@/Documents/login.png",NSHomeDirectory()];
        NSURL *url = [NSURL URLWithString:path];
        return url;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
}
@end
