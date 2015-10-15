//
//  WLICommentsViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLICommentsViewController.h"
#import "WLICommentCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"

@implementation WLICommentsViewController


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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableViewRefresh addGestureRecognizer:tapGesture];
    
    [super viewDidLoad];
    self.title = @"Comments";
    [self reloadData:YES];
}
-(void)dismissKeyboard
{
    if ([self.textFieldEnterComment isFirstResponder]) {
        [self.textFieldEnterComment resignFirstResponder];
    }

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
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 1) {
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
    
    if (indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WLIComment *comment = self.comments[indexPath.row];
        [sharedConnect removeCommentWithCommentID:comment.commentID onCompletion:^(ServerResponse serverResponseCode) {
            
        }];
    }
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return [WLICommentCell sizeWithComment:self.comments[indexPath.row]].height;
    } else if (indexPath.section == 0){
        return 44 * loadMore * self.comments.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
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
    oldViewHeight = CGRectGetHeight(self.tableViewRefresh.frame);
//    CGFloat height = keyboardFrame.origin.y - 64.0f - CGRectGetHeight(self.viewEnterComment.frame);
//    self.tableViewRefresh.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewRefresh.frame), height);
//    self.viewEnterComment.frame = CGRectMake(0.0f, CGRectGetMaxY(self.tableViewRefresh.frame), CGRectGetWidth(self.viewEnterComment.frame), CGRectGetHeight(self.viewEnterComment.frame));
    self.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewRefresh.frame), keyboardFrame.origin.y);
}

- (void)keyboardWillHide:(NSNotification *)notification {
//    CGFloat height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.viewEnterComment.frame);
//    self.tableViewRefresh.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewRefresh.frame), height);
//    self.viewEnterComment.frame = CGRectMake(0.0f, CGRectGetMaxY(self.tableViewRefresh.frame), CGRectGetWidth(self.viewEnterComment.frame), CGRectGetHeight(self.viewEnterComment.frame));
    self.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewRefresh.frame), [[UIScreen mainScreen] bounds].size.height - 60.0f);
}


@end
