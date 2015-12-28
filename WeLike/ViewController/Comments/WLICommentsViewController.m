//
//  WLICommentsViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLICommentsViewController.h"
#import "WLITimelineViewController.h"

// Cells
#import "WLICommentCell.h"
#import "WLILoadingCell.h"

static NSString *const CommentCellIdentifier = @"WLICommentCell";
static NSString *const LoadingCellIdentifier = @"WLILoadingCell";

@interface WLICommentsViewController () <WLIViewControllerRefreshProtocol>

@property (weak, nonatomic) IBOutlet UIView *viewEnterComment;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEnterComment;

@property (strong, nonatomic) NSMutableArray *comments;

@end

@implementation WLICommentsViewController

@synthesize tableViewRefresh;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.comments = [NSMutableArray array];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    self.tableViewRefresh.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.tableViewRefresh addGestureRecognizer:tapGesture];
    [self.tableViewRefresh registerNib:[UINib nibWithNibName:NSStringFromClass(WLICommentCell.class) bundle:nil] forCellReuseIdentifier:CommentCellIdentifier];
    [self.tableViewRefresh registerNib:[UINib nibWithNibName:NSStringFromClass(WLILoadingCell.class) bundle:nil] forCellReuseIdentifier:LoadingCellIdentifier];

    self.navigationItem.title = @"Comments";
    [self reloadData:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.textFieldEnterComment.text = @"";
    
    if (!loading) {
        NSMutableArray *comments = [NSMutableArray array];
        for (NSInteger i = self.comments.count - 1; i >= 0; i--) {
            id comment = self.comments[i];
            if (comment && comments.count < 3) {
                [comments addObject:comment];
            } else {
                break;
            }
        }
        self.post.postComments = comments;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    
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

#pragma mark - Gesture

- (void)dismissKeyboard
{
    if ([self.textFieldEnterComment isFirstResponder]) {
        [self.textFieldEnterComment resignFirstResponder];
    }
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
        loadMore = comments.count == kDefaultPageSize;
        [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.comments.count;
    } else {
        return loadMore;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        WLICommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        cell.comment = self.comments[indexPath.row];
        return cell;
    } else {
        WLILoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canDelete = NO;
    if (indexPath.section == 0) {
        WLIComment *comment = self.comments[indexPath.row];
        if (comment.user.userID == sharedConnect.currentUser.userID) {
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
				[WLIAnalytics eventDeleteCommentWithUserId:[WLIConnect sharedConnect].currentUser.userID withPostId:weakSelf.post.postID withCommentId:comment.commentID];
                [weakSelf.comments removeObject:comment];
                weakSelf.post.postCommentsCount--;
                [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.tableViewRefresh setEditing:NO animated:YES];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [WLICommentCell sizeWithComment:self.comments[indexPath.row]].height;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == 1 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.textFieldEnterComment.text.length) {
        [hud show:YES];
        __weak typeof(self) weakSelf = self;
        [sharedConnect sendCommentOnPostID:self.post.postID withCommentText:self.textFieldEnterComment.text onCompletion:^(WLIComment *comment, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                [hud hide:YES];
                weakSelf.post.commentedThisPost = YES;
                [weakSelf.comments addObject:comment];
                weakSelf.post.postCommentsCount++;
                [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                weakSelf.textFieldEnterComment.text = @"";
            }
        }];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - WLICellDelegate

- (void)showTimelineForSearchString:(NSString *)searchString
{
    WLITimelineViewController *timeline = [WLITimelineViewController new];
    timeline.searchString = searchString;
    timeline.navigationItem.title = searchString;
    [self.navigationController pushViewController:timeline animated:YES];
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

@end
