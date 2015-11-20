//
//  WLIChangePasswordViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/19/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIChangePasswordViewController.h"
#import "WLILoginTableViewCell.h"

@interface WLIChangePasswordViewController () <UITableViewDataSource, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UITextField *textFieldOldPassword;
@property (weak, nonatomic) UITextField *textFieldPassword;
@property (weak, nonatomic) UITextField *textFieldRepassword;

@end

@implementation WLIChangePasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Change password";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveChangesAction:)];

    [self.tableView registerNib:WLILoginTableViewCell.nib forCellReuseIdentifier:WLILoginTableViewCell.ID];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.textFieldPassword && self.textFieldRepassword && self.textFieldOldPassword) {
        toolbar.mainScrollView = self.tableView;
        toolbar.textFields = @[self.textFieldOldPassword, self.textFieldPassword, self.textFieldRepassword];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self dataFieldCellForIndexPath:indexPath];
    return cell;
}

#pragma mark - Configure cells

- (UITableViewCell *)dataFieldCellForIndexPath:(NSIndexPath *)indexPath
{
    WLILoginTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLILoginTableViewCell.ID forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textField.placeholder = @"old password";
        cell.textField.secureTextEntry = YES;
        self.textFieldOldPassword = cell.textField;
    } else if (indexPath.row == 1) {
        cell.textField.placeholder = @"password";
        cell.textField.secureTextEntry = YES;
        self.textFieldPassword = cell.textField;
    } else if (indexPath.row == 2) {
        cell.textField.placeholder = @"retype password";
        cell.textField.secureTextEntry = YES;
        self.textFieldRepassword = cell.textField;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

#pragma mark - Actions

- (void)saveChangesAction:(UIBarButtonItem *)barButtonItemSave
{
    if (!self.textFieldOldPassword.text.length || !self.textFieldPassword.text.length || !self.textFieldRepassword.text.length) {
        [self showErrorWithMessage:@"All fields are required"];
    } else if (self.textFieldPassword.text.length && self.textFieldRepassword.text.length && !self.textFieldOldPassword.text.length) {
        [self showErrorWithMessage:@"Please enter your old password"];
    } else if (self.textFieldOldPassword.text.length && (!self.textFieldRepassword.text.length || !self.textFieldPassword.text.length)) {
        [self showErrorWithMessage:@"Please enter your new password"];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [self showErrorWithMessage:@"Password and repassword doesn't match."];
    } else {
        [hud show:YES];
        NSString *password;
        if (self.textFieldPassword.text.length) {
            if (self.textFieldPassword.text.length < 4) {
                [self showErrorWithMessage:@"Your password needs to be at least 4 characters long."];
                return;
            } else {
                password = self.textFieldPassword.text;
            }
            __weak typeof(self) weakSelf = self;
            [sharedConnect changePassword:self.textFieldOldPassword.text toNewPassword:password withCompletion:^(ServerResponse serverResponseCode) {
                if (serverResponseCode == OK) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    [weakSelf showErrorWithMessage:@"Something went wrong. Please try again."];
                }
                [hud hide:YES];
            }];
        }
    }
}

#pragma mark - Alert

- (void)showErrorWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
