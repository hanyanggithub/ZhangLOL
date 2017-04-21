//
//  SmallCellModel.h
//  ZhangLOL
//
//  Created by mac on 17/4/6.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseModel.h"

@interface SmallCellModel : BaseModel

@property(nonatomic, copy)NSString *article_id;
@property(nonatomic, copy)NSString *article_url;
@property(nonatomic, copy)NSString *bmatchid;
@property(nonatomic, copy)NSString *channel_desc;
@property(nonatomic, copy)NSString *channel_id;
@property(nonatomic, copy)NSString *content_id;
@property(nonatomic, copy)NSString *image_spec;
@property(nonatomic, copy)NSString *image_url_big;
@property(nonatomic, copy)NSString *image_url_small;
@property(nonatomic, copy)NSString *image_with_btn;
@property(nonatomic, copy)NSString *insert_date;
@property(nonatomic, copy)NSString *intent;
@property(nonatomic, copy)NSString *is_act;
@property(nonatomic, copy)NSString *is_direct;
@property(nonatomic, copy)NSString *is_hot;
@property(nonatomic, copy)NSString *is_new;
@property(nonatomic, copy)NSString *is_purchase;
@property(nonatomic, copy)NSString *is_report;
@property(nonatomic, copy)NSString *is_subject;
@property(nonatomic, copy)NSString *is_top;
@property(nonatomic, copy)NSString *newstype;
@property(nonatomic, copy)NSString *newstypeid;
@property(nonatomic, copy)NSString *pics_id;
@property(nonatomic, copy)NSString *publication_date;
@property(nonatomic, copy)NSString *pv;
@property(nonatomic, copy)NSString *score;
@property(nonatomic, copy)NSString *summary;
@property(nonatomic, copy)NSString *targetid;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *v_len;


/**
 比赛特有
 */
@property(nonatomic, copy)NSString *teama_name;
@property(nonatomic, copy)NSString *teama_logo;
@property(nonatomic, copy)NSString *teamb_name;
@property(nonatomic, copy)NSString *teamb_logo;
@property(nonatomic, copy)NSString *match_name;
@property(nonatomic, copy)NSString *match_date;
@property(nonatomic, copy)NSString *march_result;


/**
 图集特有
 */
@property(nonatomic, copy)NSString *count;
@property(nonatomic, copy)NSString *big_index;
@property(nonatomic, copy)NSString *small_index;
@property(nonatomic, copy)NSString *imageset_id;
@property(nonatomic, copy)NSString *count_image_url;
@property(nonatomic, copy)NSString *big_image_url;
@property(nonatomic, copy)NSString *small_image_url;


@end
