//
//  RecommendPageControll.h
//  ZhangLOL
//
//  Created by mac on 17/4/4.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendPageControll : UIView

@property(nonatomic, assign)NSInteger pages;
@property(nonatomic, assign)NSInteger currentPage;

- (void)setIndex:(NSInteger)index;

@end
