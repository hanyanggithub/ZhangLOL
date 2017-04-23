//
//  SizeMarking.h
//  ZhangLOL
//
//  Created by mac on 17/4/18.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#ifndef SizeMarking_h
#define SizeMarking_h

#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width      // 设备屏幕宽度
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height     // 设备屏幕高度
#define SCREEN_SCALE   (SCREEN_WIDTH / 375.0)                       // 当前设备宽度与iphone6宽度的比例

#define IPHONE_4    ([UIScreen mainScreen].bounds.size.height == 480.0 ? YES : NO)  // 是否为3.5英寸屏幕
#define IPHONE_5    ([UIScreen mainScreen].bounds.size.height == 568.0 ? YES : NO)  // 是否为4.0英寸屏幕
#define IPHONE_6    ([UIScreen mainScreen].bounds.size.height == 667.0 ? YES : NO)  // 是否为4.7英寸屏幕
#define IPHONE_6P   ([UIScreen mainScreen].bounds.size.height == 736.0 ? YES : NO)  // 是否为5.5英寸屏幕

#define STATUSBAR_HEIGHT 20.0       // 状态栏高度
#define NAVI_STATUS_BAR_HEIGHT 64.0 // 导航栏+状态栏高度
#define TABBAR_HEIGHT 44.0          // 标签栏高度(底部)
#define NAVI_TITLE_FONT_SIZE (IPHONE_6P ? 16.0 * SCREEN_SCALE:16.0)  // 导航栏标题字体大小
/** 资讯 **/
// 轮播图
#define RECOMMEND_VIEW_HEIGHT 200.0                                            // 轮播广告高度
#define PAGR_CONTROLL_HEIGHT  12.0                                             // 轮播页控件高度
// 顶部标签栏
#define CHANNELBAR_HEIGHT   TABBAR_HEIGHT                                      // 频道标签栏高度
#define CHANNELBAR_LABEL_FONT_SIZE (IPHONE_6P ? 16.0 * SCREEN_SCALE:16.0)      // 频道标签字体大小
#define CHANNELBAR_MAX_TAB_COUNT 5                                             // 一屏显示的标签的最大个数
// 赛事视频悬浮
#define HOVER_VIEW_HEIGHT 64.0                  // 赛事视频悬浮视图高度
#define HOVER_VIEW_LEFT_RIGHT_SPACE 10.0        // 左右间距
#define HOVER_VIEW_UNIT_SPACE 5.0               // 子视图水平间距
#define HOVER_VIEW_TOP_BOTTOM_SPACE 5.0         // 上下间距
#define HOVER_VIEW_TITLE_FONT_SIZE   (IPHONE_6P ? 16.0 * SCREEN_SCALE:16.0)     // 标题字体大小
#define HOVER_VIEW_SUBTITLE_FONT_SIZE   (IPHONE_6P ? 15.0 * SCREEN_SCALE:15.0)  // 子标题字体大小

// 普通单元格
#define ORDINARY_CELL_HEIGHT 100.0              // 普通单元格高度
#define ORDINARY_CELL_HORIZONTAL_PADDING 6.0    // 单元格水平方向与内容视图的内间距
#define ORDINARY_CELL_VERTICAL_PADDING 2.0      // 单元格垂直方向与内容视图的内间距

#define ORDINARY_CELL_IMAGE_MARGIN_LEFT 10.0    // 图片距离父视图的左间距
#define ORDINARY_CELL_IMAGE_WIDTH 100.0         // 图片宽
#define ORDINARY_CELL_IMAGE_HEIGHT 80.0         // 图片高

#define ORDINARY_CELL_TITLE_MARGIN_TOP 5.0      // 标题距父视图的上间距
#define ORDINARY_CELL_TITLE_HEIGHT  20.0        // 标题高
#define ORDINARY_CELL_TITLE_LEFT_SPACE 5.0      // 标题距左侧图片的距离
#define ORDINARY_CELL_TITLE_MARGIN_RIGHT 10.0   // 标题距父视图的右间距

#define ORDINARY_CELL_CONTENT_TOP_SPACE 1.0    // 内容距标题的距离
#define ORDINARY_CELL_CONTENT_BOTTOM_SPACE 1.0    // 内容距类型视图的距离

#define ORDINARY_CELL_TIME_MARGIN_BOTTOM 5.0    // 时间标签距父视图的底间距
#define ORDINARY_CELL_TIME_HEIGHT       20.0    // 时间标签高度

#define ORDINARY_CELL_READ_LEFT_SPACE   5.0     // 阅读标签距时间标签的间距

#define ORDINARY_CELL_TYPE_HEIGHT   20.0  // 类型标签高度

#define ORDINARY_CELL_TITLE_FONT_SIZE (IPHONE_6P ? 15.0 * SCREEN_SCALE:15.0) // 标题字体大小
#define ORDINARY_CELL_CONTENT_FONT_SIZE (IPHONE_6P ? 13 * SCREEN_SCALE:13.0) // 内容字体大小
#define ORDINARY_CELL_TIME_FONT_SIZE (IPHONE_6P ? 11.0 * SCREEN_SCALE:11.0) // 时间，阅读量，类型字体大小



// 图集单元格
#define ATLAS_CELL_TITLE_MARGIN_TOP 5.0      // 标题距父视图的上间距
#define ATLAS_CELL_TITLE_MARGIN_LEFT 10.0   // 标题距父视图的左间距
#define ATLAS_CELL_TITLE_MARGIN_RIGHT 10.0  // 标题距父视图的右间距
#define ATLAS_CELL_TITLE_HEIGHT 20.0        // 标题高

#define ATLAS_CELL_SUBTITLE_TOP_SPACE 1.0   // 子标题距上侧视图的距离
#define ATLAS_CELL_SUBTITLE_HEIGHT 20.0     // 子标题高

#define ATLAS_CELL_IMAGE_CONTAINER_TOP_SPACE 1.0 // 图片容器视图距上侧视图的距离
#define ATLAS_CELL_IMAGE_CONTAINER_BOTTOM_SPACE 5.0 // 图片容器距下侧视图的距离

#define ATLAS_CELL_SMALL_IMAGE_WIDTH (SCREEN_WIDTH * 0.2) // 小图宽高
#define ATLAS_CELL_IMAGE_SPACE  4.0 // 图片之间的间距
#define ATLAS_CELL_BIG_IMAGE_HEIGHT (ATLAS_CELL_SMALL_IMAGE_WIDTH * 2 + ATLAS_CELL_IMAGE_SPACE) // 大图高度
#define ATLAS_CELL_BIG_IMAGE_WIDTH (SCREEN_WIDTH - ORDINARY_CELL_HORIZONTAL_PADDING * 2 -  ATLAS_CELL_TITLE_MARGIN_LEFT * 2 - ATLAS_CELL_SMALL_IMAGE_WIDTH - ATLAS_CELL_IMAGE_SPACE) // 大图宽度

#define ATLAS_CELL_HEIGHT (ORDINARY_CELL_VERTICAL_PADDING + ATLAS_CELL_TITLE_MARGIN_TOP + ATLAS_CELL_TITLE_HEIGHT + ATLAS_CELL_SUBTITLE_TOP_SPACE + ATLAS_CELL_SUBTITLE_HEIGHT +  ATLAS_CELL_IMAGE_CONTAINER_TOP_SPACE + ATLAS_CELL_BIG_IMAGE_HEIGHT + ATLAS_CELL_IMAGE_CONTAINER_BOTTOM_SPACE +  ORDINARY_CELL_TYPE_HEIGHT + ATLAS_CELL_TITLE_MARGIN_TOP + ORDINARY_CELL_VERTICAL_PADDING) // 图集单元格高度

// 专栏单元格


#endif /* SizeMarking_h */
