//
//  WLIMyDriveViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

// Controllers
#import "WLIMyDriveViewController.h"
#import "WLIFollowersViewController.h"
#import "WLIFollowingViewController.h"

// Cells
#import "WLIMyDriveHeaderCell.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"

static CGFloat const HeaderCellHeight = 156;

@interface WLIMyDriveViewController () <MyDriveHeaderCellDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) WLIUser *user;
@property (strong, nonatomic) WLIPost *morePost;
@property (assign, nonatomic) NSInteger deleteButtonIndex;

@end

@implementation WLIMyDriveViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"My Energy";
    self.tableViewRefresh.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewRefresh registerNib:WLIMyDriveHeaderCell.nib forCellReuseIdentifier:WLIMyDriveHeaderCell.ID];
    [self.tableViewRefresh registerNib:WLIPostCell.nib forCellReuseIdentifier:WLIPostCell.ID];
    [self.tableViewRefresh registerNib:WLILoadingCell.nib forCellReuseIdentifier:WLILoadingCell.ID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.user = sharedConnect.currentUser;
    if (self.user) {
        self.navigationItem.title = self.user.userUsername;
        for (WLIPost *post in self.posts) {
            post.user.userFullName = self.user.userFullName;
            post.user.userUsername = self.user.userUsername;
            post.user.userAvatarPath = self.user.userAvatarPath;
        }
        [self.tableViewRefresh reloadData];
    }
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    loading = YES;
    NSUInteger page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
        [self reloadUserInfo];
        return;
    } else {
        page = (self.posts.count / kDefaultPageSize) + 1;
    }
    
    __weak typeof(self) weakSelf = self;
    [sharedConnect mydriveTimelineForUserID:sharedConnect.currentUser.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, WLIUser *user, ServerResponse serverResponseCode) {
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

- (void)reloadUserInfo
{
    __weak typeof(self) weakSelf = self;
    [sharedConnect userWithUserID:sharedConnect.currentUser.userID onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            weakSelf.user = user;
            weakSelf.navigationItem.title = user.userUsername;
        }
        [weakSelf reloadData:NO];
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
    cell.showDeleteButton = YES;
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

#pragma mark - WLITableViewCellDelegate

- (void)deletePost:(WLIPost *)post sender:(id)senderCell
{
    self.morePost = post;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"Are you sure you want to delete this post?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        __weak typeof(self) weakSelf = self;
        [sharedConnect deletePostID:self.morePost.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                NSInteger postIndex = [weakSelf.posts indexOfObject:weakSelf.morePost];
                if (postIndex != NSNotFound) {
                    [weakSelf.posts removeObject:weakSelf.morePost];
                    [weakSelf.tableViewRefresh beginUpdates];
                    [weakSelf.tableViewRefresh deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:postIndex inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [weakSelf.tableViewRefresh endUpdates];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"An error occoured when deleting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

@end
