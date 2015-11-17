//
//  WLIFollowingsViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIFollowingsViewController.h"

@interface WLIFollowingsViewController ()

@end

@implementation WLIFollowingsViewController

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{    
    loading = YES;
    NSUInteger page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
    } else {
        page = (self.posts.count / kDefaultPageSize) + 1;
    }
    __weak typeof(self) weakSelf = self;
    [sharedConnect connectTimelineForUserID:sharedConnect.currentUser.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        loading = NO;
        if (serverResponseCode == OK) {
            if (reloadAll) {
                [weakSelf.posts removeAllObjects];
            }
            [weakSelf.posts addObjectsFromArray:posts];
        }
        loadMore = (posts.count == kDefaultPageSize);
        [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Following";
}

@end
