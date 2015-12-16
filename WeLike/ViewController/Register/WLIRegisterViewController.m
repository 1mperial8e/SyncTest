//
//  WLIRegisterViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIRegisterViewController.h"

// Cells
#import "WLIRegisterAvatarTableViewCell.h"
#import "WLIRegisterTableViewCell.h"


@interface WLIRegisterViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UITextField *textFieldEmail;
@property (weak, nonatomic) UITextField *textFieldPassword;
@property (weak, nonatomic) UITextField *textFieldRepassword;
@property (weak, nonatomic) UITextField *textFieldUsername;
@property (weak, nonatomic) UITextField *textFieldFullName;

@property (weak, nonatomic) UIImageView *avatarImageView;

@end

@implementation WLIRegisterViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Register";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.tableView registerNib:WLIRegisterAvatarTableViewCell.nib forCellReuseIdentifier:WLIRegisterAvatarTableViewCell.ID];
    [self.tableView registerNib:WLIRegisterTableViewCell.nib forCellReuseIdentifier:WLIRegisterTableViewCell.ID];
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
    
    if (self.textFieldEmail && self.textFieldPassword && self.textFieldRepassword && self.textFieldUsername && self.textFieldFullName) {
        toolbar.mainScrollView = self.tableView;
        toolbar.textFields = @[self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldUsername, self.textFieldFullName];
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
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self avatarCellForIndexPath:indexPath];
    } else {
        cell = [self dataFieldCellForIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heigh = 50.f;
    if (indexPath.row == 0) {
        heigh = 130.f;
    }
    return heigh;
}

#pragma mark - ConfigureCell

- (UITableViewCell *)avatarCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIRegisterAvatarTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLIRegisterAvatarTableViewCell.ID forIndexPath:indexPath];
    self.avatarImageView = cell.avatarImageView;
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(cell.avatarImageView.bounds) / 2;
    self.avatarImageView.layer.masksToBounds = YES;
    [cell.chooseAvatarButton addTarget:self action:@selector(selectAvatarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (UITableViewCell *)dataFieldCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIRegisterTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLIRegisterTableViewCell.ID forIndexPath:indexPath];
    if (indexPath.row == 1) {
        cell.textField.placeholder = @"email address";
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textFieldEmail = cell.textField;
    } else if (indexPath.row == 2) {
        cell.textField.placeholder = @"password";
        cell.textField.secureTextEntry = YES;
        self.textFieldPassword = cell.textField;
    } else if (indexPath.row == 3) {
        cell.textField.placeholder = @"retype password";
        cell.textField.secureTextEntry = YES;
        self.textFieldRepassword = cell.textField;
    } else if (indexPath.row == 4) {
        cell.textField.placeholder = @"username";
        self.textFieldUsername = cell.textField;
    } else if (indexPath.row == 5) {
        cell.textField.placeholder = @"full name";
        self.textFieldFullName = cell.textField;
    } else if (indexPath.row == 6) {
        cell.registerButton.hidden = NO;
        cell.textField.hidden = YES;
        [cell.registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark - Actions

- (void)selectAvatarButtonAction:(id)sender
{
    [self.tableView endEditing:NO];
    
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (void)registerButtonAction:(id)sender
{
    if (!self.textFieldEmail.text.length) {
        [self showErrorWithMessage:@"Email is required."];
    } else if (![WLIUtils isValidEmail:self.textFieldEmail.text UseHardFilter:YES]) {
        [self showErrorWithMessage:@"Email is not valid."];
    } else if (self.textFieldPassword.text.length < 4 || self.textFieldRepassword.text.length < 4) {
        [self showErrorWithMessage:@"Password is required. Your password should be at least 4 characters long."];
    } else if (!self.textFieldUsername.text.length) {
        [self showErrorWithMessage:@"Username is required."];
    } else if (![WLIUtils isValidUserName:self.textFieldUsername.text]) {
        [self showErrorWithMessage:@"Username is not valid."];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [self showErrorWithMessage:@"Password and repassword doesn't match."];
    } else if (!self.textFieldFullName.text.length) {
        [self showErrorWithMessage:@"Full Name is required."];
    } else if (!self.avatarImageView.image) {
        [self showErrorWithMessage:@"Avatar image is required."];
    } else {
        [self.view endEditing:YES];
        [hud show:YES];
        
        __weak typeof(self) weakSelf = self;
        [sharedConnect registerUserWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text email:self.textFieldEmail.text userAvatar:self.avatarImageView.image userType:WLIUserTypePerson userFullName:self.textFieldFullName.text userInfo:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
				[WLIAnalytics setUserID:[NSString stringWithFormat:@"%li",(long)[WLIConnect sharedConnect].currentUser.userID]];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } else if (serverResponseCode == NO_CONNECTION) {
                [weakSelf showErrorWithMessage:@"No connection. Please try again."];
            } else if (serverResponseCode == CONFLICT) {
                [weakSelf showErrorWithMessage:@"User already exists. Please try again."];
            } else if (serverResponseCode == FORBIDDEN) {
                [weakSelf showAlertWithSupport];
            } else if (serverResponseCode == USERNAME_EXISTS) {
                [weakSelf showErrorWithMessage:[NSString stringWithFormat:@"User \"%@\" already exists. Please try again.", weakSelf.textFieldUsername.text]];
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

- (void)showAlertWithSupport
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"We were not able to create an account. Please contact support." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Support", nil] show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self sendFeedBack:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{    
    self.avatarImageView.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - NSNotification

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.size.height + 5;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.contentInset = UIEdgeInsetsZero;
}

@end
