//
//  WLICommentsViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostViewController.h"

// Cells
#import "WLICommentCell.h"
#import "WLILoadingCell.h"

static NSString *const PostCellIdentifier = @"WLIPostCell";
static NSString *const LoadingCellIdentifier = @"WLILoadingCell";
static NSString *const CommentCellIdentifier = @"WLICommentCell";

@interface WLIPostViewController () <WLIViewControllerRefreshProtocol>

@property (weak, nonatomic) IBOutlet UIView *viewEnterComment;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEnterComment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCommentContainerBottomConstraint;

@property (strong, nonatomic) NSMutableArray *comments;

@end

@implementation WLIPostViewController

@synthesize tableViewRefresh;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Post";
    
    [self.tableViewRefresh registerNib:[UINib nibWithNibName:PostCellIdentifier bundle:nil] forCellReuseIdentifier:PostCellIdentifier];
    [self.tableViewRefresh registerNib:[UINib nibWithNibName:CommentCellIdentifier bundle:nil] forCellReuseIdentifier:CommentCellIdentifier];
    [self.tableViewRefresh registerNib:[UINib nibWithNibName:LoadingCellIdentifier bundle:nil] forCellReuseIdentifier:LoadingCellIdentifier];
    self.tableViewRefresh.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.comments = [NSMutableArray array];
    [self reloadData:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.textFieldEnterComment.text = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        WLIPostCell *postCell = [tableView dequeueReusableCellWithIdentifier:PostCellIdentifier forIndexPath:indexPath];
        postCell.delegate = self;
        postCell.post = self.post;
        cell = postCell;
    } else if (indexPath.section == 1) {
        WLICommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier forIndexPath:indexPath];
        commentCell.delegate = self;
        commentCell.comment = self.comments[indexPath.row];
        cell = commentCell;
        return cell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
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
                [weakSelf.comments insertObject:comment atIndex:0];
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
    __block CGFloat height = keyboardFrame.size.height - self.tabBarController.tabBar.frame.size.height;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        weakSelf.addCommentContainerBottomConstraint.constant = height;
        [weakSelf.view layoutIfNeeded];
    } completion:nil];
    
    self.tableViewRefresh.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        weakSelf.addCommentContainerBottomConstraint.constant = 0;
        [weakSelf.view layoutIfNeeded];
    } completion:nil];
    self.tableViewRefresh.contentInset = UIEdgeInsetsZero;
}

#pragma mark - WLIPostCellDelegate

- (void)toggleLikeForPost:(WLIPost *)post sender:(WLIPostCell *)senderCell
{
    if (post.likedThisPost) {
        [[WLIConnect sharedConnect] removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                senderCell.buttonLike.selected = NO;
                post.postLikesCount--;
                post.likedThisPost = NO;
                if (post.postLikesCount == 0) {
                    senderCell.labelLikes.hidden = YES;
                }
                senderCell.labelLikes.text = [NSString stringWithFormat:@"%zd", post.postLikesCount];
            }
        }];
    } else {
        [[WLIConnect sharedConnect] setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                senderCell.buttonLike.selected = YES;
                post.postLikesCount++;
                post.likedThisPost = YES;
                if (post.postLikesCount > 0) {
                    senderCell.labelLikes.hidden = NO;
                }
                senderCell.labelLikes.text = [NSString stringWithFormat:@"%zd", post.postLikesCount];
            }
        }];
    }
}

- (void)followUser:(WLIUser *)user sender:(id)senderCell
{
    [self follow:YES user:user cellToReload:senderCell];
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell
{
    [self follow:NO user:user cellToReload:senderCell];
}

- (void)follow:(BOOL)follow user:(WLIUser *)user cellToReload:(WLIPostCell *)cell
{
    __block NSIndexPath *indexPath = [self.tableViewRefresh indexPathForCell:cell];
    __weak typeof(self) weakSelf = self;
    void (^followUserCompletion)(WLIFollow *, ServerResponse) = ^(WLIFollow *wliFollow, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            user.followingUser = follow;
            cell.post.user = user;
            if (indexPath) {
                [weakSelf.tableViewRefresh reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } else {
            NSString *message = @"An error occured, user was not followed.";
            if (!follow) {
                message = @"An error occured, user was not unfollowed.";
            }
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:message
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    };
    if (follow) {
        [sharedConnect setFollowOnUserID:user.userID onCompletion:followUserCompletion];
    } else {
        [sharedConnect removeFollowWithFollowID:user.userID onCompletion:^(ServerResponse serverResponseCode) {
            followUserCompletion(nil, serverResponseCode);
        }];
    }
}

@end
