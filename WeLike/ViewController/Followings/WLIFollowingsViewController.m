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

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Following";
    }
    return self;
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    NSUInteger page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
    } else {
        page  = (self.posts.count / kDefaultPageSize) + 1;
    }
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        loading = NO;
        self.posts = posts;
        loadMore = posts.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
