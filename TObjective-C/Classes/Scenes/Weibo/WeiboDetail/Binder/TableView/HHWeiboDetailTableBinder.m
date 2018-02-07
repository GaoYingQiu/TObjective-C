//
//  HHWeiboDetailTableBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
#import <MJRefresh/MJRefresh.h>
#import "ReactiveCocoa.h"

#import "HHFoundation.h"

#import "HHWeiboDetailTableBinder.h"

@interface HHWeiboDetailTableBinder ()

@end

@implementation HHWeiboDetailTableBinder

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UITableView *listView = self.tableView;
    if (!listView.isFirstScrollResponder ||
        listView.contentOffset.y <= 0) {
        listView.contentOffset = CGPointZero;
    }
    listView.showsVerticalScrollIndicator = listView.isFirstScrollResponder;
}

#pragma mark - Override

- (void)refreshData {
    if (self.viewModel.allData.count == 0) {
        [self.tableView showHUD];
    }
    [self.viewModel.refreshCommand execute:nil];
}

- (void)bindTableHeader {
    
    @weakify(self);
    [[self.viewModel.refreshCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        @strongify(self);
        
        self.tableView.errorView.hidden = YES;
        [self.tableView hideHUD];
        [self.tableView.mj_footer resetNoMoreData];
        [self.tableView reloadData];
    }];
    
    [self.viewModel.refreshCommand.errors subscribeNext:^(NSError *error) {
        @strongify(self);
        [self.tableView hideHUD];
    }];
}

@end
