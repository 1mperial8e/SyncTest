//
//  WLIFollowingViewController.m
//  WeLike
//
//  Created by Planet 1107 on 03/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLIFollowingViewController.h"

@implementation WLIFollowingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Following";
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    loading = YES;
    if (reloadAll && !loadMore) {
        loadMore = YES;
        [self.tableViewRefresh insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    NSUInteger page = reloadAll ? 1 : (self.people.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    [sharedConnect followingForUserID:self.user.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *following, ServerResponse serverResponseCode) {
        [weakSelf downloadedPeople:following serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
    
}

@end
