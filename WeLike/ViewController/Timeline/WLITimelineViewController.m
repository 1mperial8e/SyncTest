//
//  WLITimelineViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITimelineViewController.h"
#import "GlobalDefines.h"

@implementation WLITimelineViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Timeline";
        self.searchString = @"";
    }
    return self;
}


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
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID withCategory:0 countryID:0 searchString:self.searchString page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
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

@end
