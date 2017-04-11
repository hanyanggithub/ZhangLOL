//
//  SpecialModel.h
//  ZhangLOL
//
//  Created by mac on 17/4/8.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseModel.h"

typedef NS_ENUM(NSInteger, SpecialType) {
    /* 未订阅 */
    SpecialTypeUnbook,
    /* 订阅 */
    SpecialTypeBook,
    /* 推荐 */
    SpecialTypeRecommend
};

@interface SpecialModel : BaseModel

@property(nonatomic, copy)NSString *author;
@property(nonatomic, copy)NSString *book_num;
@property(nonatomic, copy)NSString *col_des;
@property(nonatomic, copy)NSString *col_id;
@property(nonatomic, copy)NSString *col_title;
@property(nonatomic, copy)NSString *col_weight;
@property(nonatomic, copy)NSString *is_book;
@property(nonatomic, copy)NSString *is_hot;
@property(nonatomic, copy)NSString *is_new;
@property(nonatomic, copy)NSString *last_news_title;
@property(nonatomic, copy)NSString *last_update;
@property(nonatomic, copy)NSString *logo;
// custom
@property(nonatomic, assign)SpecialType type;       // unbook_list / book_list / recommend_list 决定分组
@property(nonatomic, assign)BOOL hasnext;           // 是否支持加载更多



@end