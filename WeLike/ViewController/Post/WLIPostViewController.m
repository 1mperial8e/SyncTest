//
//  WLICommentsViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostViewController.h"
#import "WLIFullScreenPhotoViewController.h"
#import "WLITimelineViewController.h"

// Cells
#import "WLICommentCell.h"

@interface WLIPostViewController () <WLIViewControllerRefreshProtocol>

@property (strong, nonatomic) IBOutlet UIView *viewEnterComment;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEnterComment;

@property (strong, nonatomic) NSMutableArray *comments;

@end

@implementation WLIPostViewController

@synthesize tableViewRefresh;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Post";
    
    [self.tableViewRefresh registerNib:WLICommentCell.nib forCellReuseIdentifier:WLICommentCell.ID];
    [self.tableViewRefresh registerNib:WLIPostCell.nib forCellReuseIdentifier:WLIPostCell.ID];
    [self.tableViewRefresh registerNib:WLILoadingCell.nib forCellReuseIdentifier:WLILoadingCell.ID];

    self.tableViewRefresh.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.comments = [NSMutableArray array];
    [self reloadData:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followedUserNotification:) name:FollowerUserNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.textFieldEnterComment.text = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    return self.viewEnterComment;
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    loading = YES;
    NSUInteger page = reloadAll ? 1 : (self.comments.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    [sharedConnect commentsForPostID:self.post.postID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *comments, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [weakSelf.comments removeAllObjects];
        }
        [weakSelf.comments addObjectsFromArray:comments];
        loadMore = (comments.count == kDefaultPageSize);
        [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.comments.count;
    }
    return loadMore;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        WLIPostCell *postCell = [tableView dequeueReusableCellWithIdentifier:WLIPostCell.ID forIndexPath:indexPath];
        postCell.delegate = self;
        postCell.post = self.post;
        cell = postCell;
    } else if (indexPath.section == 1) {
        WLICommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:WLICommentCell.ID forIndexPath:indexPath];
        commentCell.delegate = self;
        commentCell.comment = self.comments[indexPath.row];
        cell = commentCell;
        return cell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:WLILoadingCell.ID forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canDelete = NO;
    if (indexPath.section == 1) {
        WLIComment *comment = self.comments[indexPath.row];
        if (comment.user.userID == sharedConnect.currentUser.userID) {
            canDelete = YES;
        }
        if (self.post.user.userID == sharedConnect.currentUser.userID) {
            canDelete = YES;
        }
    } else {
        canDelete = NO;
    }
    return canDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WLIComment *comment = self.comments[indexPath.row];
        [hud show:YES];
        __weak typeof(self) weakSelf = self;
        [sharedConnect removeCommentWithCommentID:comment.commentID onCompletion:^(ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
                [weakSelf.comments removeObject:comment];
                weakSelf.post.postCommentsCount--;
                [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.tableViewRefresh setEditing:NO animated:YES];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [WLIPostCell sizeWithPost:self.post withWidth:self.view.frame.size.width].height;
    } else if (indexPath.section == 1) {
        return [WLICommentCell sizeWithComment:self.comments[indexPath.row]].height;
    }
    return 44 * loadMore;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.textFieldEnterComment.text.length) {
        [hud show:YES];
        __weak typeof(self) weakSelf = self;
        [sharedConnect sendCommentOnPostID:self.post.postID withCommentText:self.textFieldEnterComment.text onCompletion:^(WLIComment *comment, ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
                weakSelf.post.commentedThisPost = YES;
                weakSelf.post.postCommentsCount++;
                [weakSelf.comments addObject:comment];
                [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
                weakSelf.textFieldEnterComment.text = @"";
            }
        }];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - NSNotification

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.size.height - self.tabBarController.tabBar.frame.size.height;
    self.tableViewRefresh.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableViewRefresh.contentInset = UIEdgeInsetsZero;
}

- (void)followedUserNotification:(NSNotification *)notification
{
    NSInteger userId = [notification.userInfo[@"userId"] integerValue];
    BOOL followed = [notification.userInfo[@"followed"]  boolValue];

    if (self.post.user.userID == userId) {
        self.post.user.followingUser = followed;
        [self.tableViewRefresh beginUpdates];
        [self.tableViewRefresh reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableViewRefresh endUpdates];
    }
}

#pragma mark - WLIPostCellDelegate

- (void)showImageForPost:(WLIPost *)post sender:(id)senderCell
{
    if (!self.post.postVideoPath.length) {
        [self showFullImageForCell:senderCell];
    } else {
        [super showImageForPost:post sender:senderCell];
    }
}

- (void)showTimelineForSearchString:(NSString *)searchString
{
    WLITimelineViewController *timeline = [WLITimelineViewController new];
    timeline.searchString = searchString;
    timeline.navigationItem.title = searchString;
    [self.navigationController pushViewController:timeline animated:YES];
}

#pragma mark - FullImage

- (void)showFullImageForCell:(WLIPostCell *)cell
{
    if (cell.originalImage) {
        CGRect imageViewRect = cell.imageViewPostImage.superview.frame;
        imageViewRect.origin.x = ([UIScreen mainScreen].bounds.size.width - imageViewRect.size.width) / 2;
        imageViewRect.origin.y += -self.tableViewRefresh.contentOffset.y + imageViewRect.origin.x;
        WLIFullScreenPhotoViewController *imageController = [WLIFullScreenPhotoViewController new];
        imageController.image = cell.originalImage;
        imageController.presentationRect = imageViewRect;
        imageController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self.tabBarController presentViewController:imageController animated:NO completion:nil];
    }
}

@end
