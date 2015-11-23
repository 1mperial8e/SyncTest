//
//  WLIUserDriveViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/20/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIUserDriveViewController.h"

static CGFloat const HeaderCellHeight = 156;

@interface WLIUserDriveViewController ()

@end

@implementation WLIUserDriveViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    self.postsSectionNumber = 1;
    
    [super viewDidLoad];
    self.navigationItem.title = self.user.userUsername;
    self.tableViewRefresh.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewRefresh registerNib:WLIMyDriveHeaderCell.nib forCellReuseIdentifier:WLIMyDriveHeaderCell.ID];
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    loading = YES;
    if (reloadAll && !loadMore) {
        loadMore = YES;
        [self.tableViewRefresh insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:self.postsSectionNumber + 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if (reloadAll) {
        [self reloadUserInfo];
    }
    NSUInteger page = reloadAll ? 1 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    [sharedConnect mydriveTimelineForUserID:self.user.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, WLIUser *user, ServerResponse serverResponseCode) {
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

- (void)reloadUserInfo
{
    __weak typeof(self) weakSelf = self;
    [sharedConnect userWithUserID:self.user.userID onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            user.followingUser = weakSelf.user.followingUser;
            weakSelf.user = user;
            weakSelf.navigationItem.title = user.userUsername;
            [weakSelf.tableViewRefresh beginUpdates];
            [weakSelf.tableViewRefresh reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableViewRefresh endUpdates];
        }
    }];
}

#pragma mark - MyDriveHeaderCellDelegate

- (void)showFollowersList
{
    WLIFollowersViewController *followersViewController = [WLIFollowersViewController new];
    followersViewController.user = self.user;
    [self.navigationController pushViewController:followersViewController animated:YES];
}

- (void)showFollowingsList
{
    WLIFollowingViewController *followingsViewController = [WLIFollowingViewController new];
    followingsViewController.user = self.user;
    [self.navigationController pushViewController:followingsViewController animated:YES];
}

- (void)follow:(BOOL)follow user:(WLIUser *)user
{
    if (follow) {
        [sharedConnect setFollowOnUserID:user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            
        }];
    } else {
        [sharedConnect removeFollowWithFollowID:user.userID onCompletion:^(ServerResponse serverResponseCode) {
            
        }];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.posts.count;
    } else {
        return loadMore;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self headerCellForIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        cell = [self postCellForIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:WLILoadingCell.ID forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Configure cells

- (UITableViewCell *)headerCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIMyDriveHeaderCell *cell = [self.tableViewRefresh dequeueReusableCellWithIdentifier:WLIMyDriveHeaderCell.ID forIndexPath:indexPath];
    cell.delegate = self;
    cell.user = self.user;
    return cell;
}

- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIPostCell *cell = [self.tableViewRefresh dequeueReusableCellWithIdentifier:WLIPostCell.ID forIndexPath:indexPath];
    cell.delegate = self;
    cell.showDeleteButton = NO;
    cell.post = self.posts[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return HeaderCellHeight;
    } else if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row] withWidth:self.view.frame.size.width].height;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

#pragma mark - Notifications

- (void)followedUserNotification:(NSNotification *)notification
{
    NSInteger userId = [notification.userInfo[@"userId"] integerValue];
    BOOL followed = [notification.userInfo[@"followed"]  boolValue];
    if (self.user.userID == userId) {
        self.user.followingUser = followed;
        [self.tableViewRefresh beginUpdates];
        [self.tableViewRefresh reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableViewRefresh endUpdates];
    }
    [super followedUserNotification:notification];
}

@end
