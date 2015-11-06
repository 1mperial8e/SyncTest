//
//  WLIMyDriveViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMyDriveViewController.h"
#import "WLIMyDriveHeaderCell.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"

static CGFloat const HeaderCellHeight = 156;

@interface WLIMyDriveViewController ()

@end

@implementation WLIMyDriveViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"My Energy";
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    NSUInteger page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
        [self.posts removeAllObjects];
        [self reloadUserInfo];
        return;
    } else {
        page  = (self.posts.count / kDefaultPageSize) + 1;
    }
    
    __weak typeof(self) weakSelf = self;
    [sharedConnect mydriveTimelineForUserID:sharedConnect.currentUser.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, WLIUser *user, ServerResponse serverResponseCode) {
        loading = NO;
        [weakSelf.posts addObjectsFromArray:posts];
        loadMore = (posts.count == kDefaultPageSize);
        [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIMyDriveHeaderCell";
        WLIMyDriveHeaderCell *cell = (WLIMyDriveHeaderCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIMyDriveHeaderCell" owner:self options:nil] lastObject];
        }
        cell.user = self.user;
        return cell;
    } else if (indexPath.section == 2){
        static NSString *CellIdentifier = @"WLIPostCell";
        WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
            cell.delegate = self;
            cell.showDeleteButton = YES;
        }
        cell.post = self.posts[indexPath.row];
        return cell;
    } else {

        static NSString *CellIdentifier = @"WLILoadingCell";
        WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
        }
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return 1;
    } else if (section == 2) {
            return self.posts.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return HeaderCellHeight;
    } else if (indexPath.section == 2) {
            return [WLIPostCell sizeWithPost:self.posts[indexPath.row] withWidth:self.view.frame.size.width].height;
    } else if (indexPath.section == 0){
        return 0; //44 * loading * self.posts.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

- (void)deletePost:(WLIPost *)post sender:(id)senderCell {
    morePost = post;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"Are you sure you want to delete this post" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    deleteButtonIndex = [alert addButtonWithTitle:@"Yes"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == deleteButtonIndex) {
        [sharedConnect deletePostID:morePost.postID onCompletion:^(ServerResponse serverResponseCode) {
//            if (serverResponseCode == OK)
//            {
                [self.posts removeObject:morePost];
                [self.tableViewRefresh reloadData];
//            }
//            else
//            {
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"An error occoured when deleting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//            }
        }];
    }
}
- (void)showMoreForPost:(WLIPost*)post sender:(id)senderCell
{
    morePost = post;
    [[[UIActionSheet alloc] initWithTitle:post.postTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete post", nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete post"]) {
        // Delete
        [self deletePost:morePost sender:self];

    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Share"]) {
        [self showShareForPost:morePost sender:self];
    }
}

@end
