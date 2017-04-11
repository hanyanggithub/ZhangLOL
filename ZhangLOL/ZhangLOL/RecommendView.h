//
//  RecommendView.h
//  ZhangLOL
//
//  Created by mac on 17/4/4.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecommendView : UIView

- (void)updateWithModels:(NSArray *)models;
- (UIImage *)getCurrentShowImage;

@end
