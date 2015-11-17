//
//  WLILoginViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

// Controllers
#import "WLILoginViewController.h"
#import "WLITimelineViewController.h"

// Cells
#import "WLILoginTableViewCell.h"

// Models
#import "WLIAppDelegate.h"

@interface WLILoginViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UITextField *usernameTextField;
@property (weak, nonatomic) UITextField *passwordTextField;

@end

@implementation WLILoginViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Login";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.tableView registerNib:WLILoginTableViewCell.nib forCellReuseIdentifier:WLILoginTableViewCell.ID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.usernameTextField && self.passwordTextField) {
        toolbar.mainScrollView = self.tableView;
        toolbar.textFields = @[self.usernameTextField, self.passwordTextField];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLILoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WLILoginTableViewCell.ID forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textField.placeholder = @"Email or username";
        self.usernameTextField = cell.textField;
    } else if (indexPath.row == 1) {
        cell.textField.placeholder = @"password";
        self.passwordTextField = cell.textField;
        self.passwordTextField.secureTextEntry = YES;
    } else {
        cell.textField.hidden = YES;
        cell.loginButton.hidden = NO;
        __weak typeof(self) weakSelf = self;
        cell.loginHandler = ^{
            [weakSelf loginWithUsername:weakSelf.usernameTextField.text andPassword:weakSelf.passwordTextField.text];
        };
    }
    return cell;
}

#pragma mark - Login

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    if (!username.length) {
        [self showErrorWithMessage:@"Username is required."];
    } else if (!password.length) {
        [self showErrorWithMessage:@"Password is required."];
    } else {
        [self.view endEditing:YES];
        [hud show:YES];
        __weak typeof(self) weakSelf = self;
        [sharedConnect loginWithUsername:username andPassword:password onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
                    WLITimelineViewController *timelineViewController = (WLITimelineViewController *)[appDelegate.tabBarController.viewControllers[0] topViewController];
                    [timelineViewController reloadData:YES];
                }];
            } else if (serverResponseCode == NO_CONNECTION) {
                [weakSelf showErrorWithMessage:@"No connection. Please try again."];
            } else if (serverResponseCode == NOT_FOUND) {
                [weakSelf showErrorWithMessage:@"Wrong username. Please try again."];
            } else if (serverResponseCode == UNAUTHORIZED) {
                [weakSelf showErrorWithMessage:@"Wrong password. Please try again."];
            } else {
                [weakSelf showErrorWithMessage:@"Something went wrong. Please try again."];
            }
        }];
    }
}

#pragma mark - Alert

- (void)showErrorWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - NSNotification

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.origin.y;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.contentInset = UIEdgeInsetsZero;
}

@end
