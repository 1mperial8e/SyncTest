//
//  WLIForgotPasswordViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/20/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIForgotPasswordViewController.h"
#import "WLILoginTableViewCell.h"

@interface WLIForgotPasswordViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *confirmationView;

@end

@implementation WLIForgotPasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Reset password";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.tableView registerNib:WLILoginTableViewCell.nib forCellReuseIdentifier:WLILoginTableViewCell.ID];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLILoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WLILoginTableViewCell.ID forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textField.placeholder = @"your email";
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField = cell.textField;
    } else if (indexPath.row == 1) {
        cell.textField.hidden = YES;
        cell.loginButton.hidden = NO;
        [cell.loginButton setTitle:@"Reset password" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        cell.loginHandler = ^{
            [weakSelf forgotPassword];
        };
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
}

#pragma mark - Reset password

- (void)forgotPassword
{
    if (!self.emailTextField.text.length) {
        [self showErrorWithMessage:@"Email is required."];
    } else if (![self isValidEmail:self.emailTextField.text UseHardFilter:YES]) {
        [self showErrorWithMessage:@"Email is not valid."];
    } else {
        [hud show:YES];
        __weak typeof(self) weakSelf = self;
        [sharedConnect forgotPasswordWithEmail:self.emailTextField.text onCompletion:^(ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
                [weakSelf showConfirmView];
            } else {
                [weakSelf showErrorWithMessage:@"Something went wrong. Please try again."];
            }
        }];
    }
}

- (BOOL)isValidEmail:(NSString *)email UseHardFilter:(BOOL)filter
{
    BOOL stricterFilter = filter;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@{1}([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)showConfirmView
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.27 animations:^{
        weakSelf.tableView.alpha = 0;
        weakSelf.confirmationView.alpha = 1;
    }];
}

#pragma mark - Alert

- (void)showErrorWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
