//
//  WLILikersViewController.m
//  MyDrive
//
//  Created by Roman R on 02.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLILikersViewController.h"

@interface WLILikersViewController ()

@end

@implementation WLILikersViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Likes";
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
	[sharedConnect followersForUserID:self.user.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *followers, ServerResponse serverResponseCode) {
		[weakSelf downloadedPeople:followers serverResponse:serverResponseCode reloadAll:reloadAll];
	}];
	
}


@end
