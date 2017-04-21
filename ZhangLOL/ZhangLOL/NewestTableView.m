//
//  NewestTableView.m
//  ZhangLOL
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 rengukeji. All rights reserved.
//


#import "NewestTableView.h"
#import "MessageScrollView.h"
#import "SmallCell.h"
#import "AtlasCell.h"
#import "ClubCell.h"
#import "SmallCellModel.h"

static NSString *usualCellId = @"usualCellId";
static NSString *atlasCellId = @"atlasCellId";
static NSString *clubCellId = @"clubCellId";

@interface NewestTableView ()<UITableViewDataSource>

@end

@implementation NewestTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.models == nil) {
        return 0;
    }else{
        return self.models.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewestBaseCell *cell = nil;
    NSString *reuseId = nil;
    Class cellClass = nil;
    SmallCellModel *model = self.models[indexPath.row];
    if ([model.newstype isEqualToString:@"图集"]) {
        reuseId = atlasCellId;
        cellClass = [AtlasCell class];
    }
//    else if ([model.newstype isEqualToString:@"俱乐部"]) {
//        reuseId = clubCellId;
//        cellClass = [ClubCell class];
//    }
    else{
        reuseId = usualCellId;
        cellClass = [SmallCell class];
    }
    // 1.当前表视图寻找可复用单元格
    cell = (NewestBaseCell *)[tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        // 2.跨表视图复用
        if ([self.superview isKindOfClass:[MessageScrollView class]]) {
            MessageScrollView *superView = (MessageScrollView *)self.superview;
            NSArray *resuabel = superView.reusableTables;
            for (UITableView *reusableTableView in resuabel) {
                cell = [reusableTableView dequeueReusableCellWithIdentifier:reuseId];
                if (cell) {
                    break;
                }
            }
        }
        
    }
    
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.model = model;
    return cell;
}
- (void)updateWithDataModels:(NSArray *)models dataInfo:(NSDictionary *)dataInfo {
    // 判断数据的变化(单个刷新单元格还是全刷)
    if (self.models == nil) {
        self.models = models;
    }
    [self reloadData];
    
}




@end
