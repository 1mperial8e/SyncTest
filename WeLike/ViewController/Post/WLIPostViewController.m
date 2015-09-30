//
//  WLICommentsViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostViewController.h"
#import "WLICommentCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"

@implementation WLIPostViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.comments = [NSMutableArray array];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Post";
    [self reloadData:YES];
    
    UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reportButton.adjustsImageWhenHighlighted = NO;
    reportButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    [reportButton setImage:[UIImage imageNamed:@"nav-btn-close"] forState:UIControlStateNormal];
    [reportButton addTarget:self action:@selector(barButtonItemReportTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reportButton];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.textFieldEnterComment.text = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    NSUInteger page = reloadAll ? 1 : (self.comments.count / kDefaultPageSize) + 1;
    [sharedConnect commentsForPostID:self.post.postID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *comments, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [self.comments removeAllObjects];
        }
        [self.comments addObjectsFromArray:comments];
        loadMore = comments.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIPostCell";
        WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.post = self.post;
        return cell;
        
    } else if (indexPath.section == 2) {
        static NSString *CellIdentifier = @"WLICommentCell";
        WLICommentCell *cell = (WLICommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLICommentCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.comment = self.comments[indexPath.row];
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
        return self.comments.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WLIComment *comment = self.comments[indexPath.row];
        [sharedConnect removeCommentWithCommentID:comment.commentID onCompletion:^(ServerResponse serverResponseCode) { }];
    }
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.post].height;
    } else if (indexPath.section == 2){
        return [WLICommentCell sizeWithComment:self.comments[indexPath.row]].height;
    } else if (indexPath.section == 0){
        return 44 * loadMore * self.comments.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 3 && loadMore && !loading) {
        [self reloadData:NO];
    }
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (self.textFieldEnterComment.text.length) {
        [hud show:YES];
        [sharedConnect sendCommentOnPostID:self.post.postID withCommentText:self.textFieldEnterComment.text onCompletion:^(WLIComment *comment, ServerResponse serverResponseCode) {
            [hud hide:YES];
            [self.comments insertObject:comment atIndex:0];
            [self.tableViewRefresh reloadData];
            self.textFieldEnterComment.text = @"";
        }];
    }
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - NSNotification methods

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.origin.y - 64.0f - CGRectGetHeight(self.viewEnterComment.frame);
    self.tableViewRefresh.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewRefresh.frame), height);
    self.viewEnterComment.frame = CGRectMake(0.0f, CGRectGetMaxY(self.tableViewRefresh.frame), CGRectGetWidth(self.viewEnterComment.frame), CGRectGetHeight(self.viewEnterComment.frame));
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGFloat height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.viewEnterComment.frame);
    self.tableViewRefresh.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewRefresh.frame), height);
    self.viewEnterComment.frame = CGRectMake(0.0f, CGRectGetMaxY(self.tableViewRefresh.frame), CGRectGetWidth(self.viewEnterComment.frame), CGRectGetHeight(self.viewEnterComment.frame));
}


#pragma mark - WLIPostCellDelegate methods

- (void)toggleLikeForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell {
    
    if (post.likedThisPost) {
        [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-like"] forState:UIControlStateNormal];
        post.postLikesCount--;
        post.likedThisPost = NO;
        if (post.postLikesCount == 1) {
            [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d like", post.postLikesCount]];
        } else {
            [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d likes", post.postLikesCount]];
        }
        [[WLIConnect sharedConnect] removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-liked"] forState:UIControlStateNormal];
                post.postLikesCount++;
                post.likedThisPost = YES;
                if (post.postLikesCount == 1) {
                    [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d like", post.postLikesCount]];
                } else {
                    [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d likes", post.postLikesCount]];
                }
            }
        }];
    } else {
        [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-liked"] forState:UIControlStateNormal];
        post.postLikesCount++;
        post.likedThisPost = YES;
        if (post.postLikesCount == 1) {
            [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d like", post.postLikesCount]];
        } else {
            [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d likes", post.postLikesCount]];
        }
        [[WLIConnect sharedConnect] setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-like"] forState:UIControlStateNormal];
                post.postLikesCount--;
                post.likedThisPost = NO;
                if (post.postLikesCount == 1) {
                    [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d like", post.postLikesCount]];
                } else {
                    [senderCell.labelLikes setText:[NSString stringWithFormat:@"%d likes", post.postLikesCount]];
                }
            }
        }];
    }
}


#pragma mark - Actions methods

- (void)barButtonItemReportTouchUpInside:(UIBarButtonItem *)barButtonItem {
    
    if ([MFMailComposeViewController canSendMail]) {
        [[[UIAlertView alloc] initWithTitle:@"Report" message:@"Are you sure you want to report this post?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Report!", nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Report" message:@"This device is not configured to send mails, please enable mail and contact us at post@appmedia.no" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    if (result == MFMailComposeResultFailed) {
        [[[UIAlertView alloc] initWithTitle:@"Mail not sent!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:^{ }];
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"Report"] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report!"]) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.navigationBar.tintColor = [UIColor whiteColor];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setToRecipients:@[@"post@appmedia.no"]];
        [mailComposeViewController setSubject:@"Report"];
        NSString *message = [NSString stringWithFormat:@"Reporting post with id: %d\n\nDescription: %@", self.post.postID, self.post.postTitle];
        [mailComposeViewController setMessageBody:message isHTML:NO];
        [self presentViewController:mailComposeViewController animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    }
}

@end
