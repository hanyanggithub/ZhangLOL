//
//  RencommendModel.h
//  ZhangLOL
//
//  Created by mac on 17/4/4.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseModel.h"

@interface RencommendModel : BaseModel

@property(nonatomic, copy)NSString *article_id;
@property(nonatomic, copy)NSString *article_url;
@property(nonatomic, copy)NSString *channel_desc;
@property(nonatomic, copy)NSString *channel_id;
@property(nonatomic, copy)NSString *content_id;
@property(nonatomic, copy)NSString *image_spec;
@property(nonatomic, copy)NSString *image_url_big;
@property(nonatomic, copy)NSString *image_url_small;
@property(nonatomic, copy)NSString *image_with_btn;
@property(nonatomic, copy)NSString *insert_date;
@property(nonatomic, copy)NSString *is_act;
@property(nonatomic, copy)NSString *is_direct;
@property(nonatomic, copy)NSString *is_hot;
@property(nonatomic, copy)NSString *is_new;
@property(nonatomic, copy)NSString *is_report;
@property(nonatomic, copy)NSString *is_subject;
@property(nonatomic, copy)NSString *is_top;
@property(nonatomic, copy)NSString *publication_date;
@property(nonatomic, copy)NSString *score;
@property(nonatomic, copy)NSString *summary;
@property(nonatomic, copy)NSString *targetid;
@property(nonatomic, copy)NSString *title;


@end
