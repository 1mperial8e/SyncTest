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
    if (reloadAll) {
        loadMore = YES;
    }
    NSUInteger page = reloadAll ? 1 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    [sharedConnect connectTimelineForUserID:sharedConnect.currentUser.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.postsSectionNumber = 0;
    
    [super viewDidLoad];
    self.navigationItem.title = @"Following";
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonAction:)];
}

@end
