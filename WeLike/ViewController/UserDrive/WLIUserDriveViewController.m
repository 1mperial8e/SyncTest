//
//  WLIUserDriveViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/20/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIUserDriveViewController.h"
#import "WLIFullScreenPhotoViewController.h"

static CGFloat const HeaderCellHeight = 156;

@interface WLIUserDriveViewController ()

@property (weak, nonatomic) WLIMyDriveHeaderCell *headerCell;
@property (assign, nonatomic) NSInteger rank;
@property (assign, nonatomic) NSInteger users;
@property (assign, nonatomic) NSInteger points;

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
    if (reloadAll) {
        loadMore = YES;
    }
    if (reloadAll) {
        [self reloadUserInfo];
    }
    NSUInteger page = reloadAll ? 1 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    [sharedConnect mydriveTimelineForUserID:self.user.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, NSDictionary *rankInfo, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            weakSelf.rank = [rankInfo[@"stored"][@"rank"] integerValue];
            weakSelf.users = [rankInfo[@"stored"][@"number_of_users"] integerValue];
            weakSelf.points = [rankInfo[@"live"][@"points"] integerValue];
            if (weakSelf.user.userID == sharedConnect.currentUser.userID) {
                sharedConnect.currentUser = weakSelf.user;
                [sharedConnect saveCurrentUser];
            }
            [weakSelf.headerCell updateRank:weakSelf.rank forUsers:weakSelf.users];
            [weakSelf.headerCell updatePoints:weakSelf.points];
        }
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

- (void)reloadUserInfo
{
    __weak typeof(self) weakSelf = self;
    [sharedConnect userWithUserID:self.user.userID onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            weakSelf.user = user;
            weakSelf.navigationItem.title = user.userUsername;
            [weakSelf.tableViewRefresh reloadData];
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

- (void)showAvatarForCell:(WLIMyDriveHeaderCell *)cell
{
    NSData *defaultAvatarData = UIImagePNGRepresentation(DefaultAvatar);
    if (cell.imageViewUser.image) {
        NSData *imageData = UIImagePNGRepresentation(cell.imageViewUser.image);
        if (![imageData isEqualToData:defaultAvatarData]) {
            CGRect frame = [self.view convertRect:cell.imageViewUser.frame fromView:self.tableViewRefresh];
            WLIFullScreenPhotoViewController *imageController = [WLIFullScreenPhotoViewController new];
            imageController.image = cell.imageViewUser.image;
            imageController.presentationRect = frame;
            imageController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self.tabBarController presentViewController:imageController animated:NO completion:nil];
        }
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
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self headerCellForIndexPath:indexPath];
        self.headerCell = (WLIMyDriveHeaderCell *)cell;
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
	[cell updateRank:self.rank forUsers:self.users];
	[cell updatePoints:self.points];
    return cell;
}

- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIPostCell *cell = [self.tableViewRefresh dequeueReusableCellWithIdentifier:WLIPostCell.ID forIndexPath:indexPath];
    cell.delegate = self;
    cell.showDeleteButton = YES;
    cell.showFollowButton = NO;
    cell.post = self.posts[indexPath.row];
	[cell blockUserInteraction];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WLIMyDriveHeaderCell" owner:self options:nil];		
		WLIMyDriveHeaderCell *cell = [topLevelObjects firstObject];
        cell.user = self.user;
        CGSize size = CGSizeZero;
        if (cell.user.userInfo.length) {
            size = [cell.myGoalsTextView sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 32, MAXFLOAT)]; // 32 spacings
        }
		NSInteger labelsHeight = 1;
		if (self.user.userTitle.length > 0) {
			labelsHeight += 22;
		}
		if (self.user.userDepartment.length > 0) {
			labelsHeight += 22;
		}
		return size.height + labelsHeight + HeaderCellHeight;
    } else if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row] withWidth:self.view.frame.size.width].height;
    } else {
        return loadMore ? 44 : 0;
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
