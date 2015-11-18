//
//  WLIEditProfileViewController.m
//  WeLike
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIEditProfileViewController.h"

// Cells
#import "WLIRegisterAvatarTableViewCell.h"
#import "WLIRegisterTableViewCell.h"

// Models
#import "WLIAppDelegate.h"

@interface WLIEditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UITextField *textFieldEmail;
@property (weak, nonatomic) UITextField *textFieldOldPassword;
@property (weak, nonatomic) UITextField *textFieldPassword;
@property (weak, nonatomic) UITextField *textFieldRepassword;
@property (weak, nonatomic) UITextField *textFieldUsername;
@property (weak, nonatomic) UITextField *textFieldFullName;

@property (weak, nonatomic) UIImageView *avatarImageView;

@property (assign, nonatomic) BOOL imageReplaced;

@end

@implementation WLIEditProfileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Edit Profile";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveChangesAction:)];
    if (self.navigationController.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cacelAction:)];
    }

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
        toolbar.textFields = @[self.textFieldEmail, self.textFieldOldPassword, self.textFieldPassword, self.textFieldRepassword, /*self.textFieldUsername,*/ self.textFieldFullName];
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
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:sharedConnect.currentUser.userAvatarPath]];
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
        self.textFieldEmail.text = sharedConnect.currentUser.userEmail;
    } else if (indexPath.row == 2) {
        cell.textField.placeholder = @"old password";
        cell.textField.secureTextEntry = YES;
        self.textFieldOldPassword = cell.textField;
    } else if (indexPath.row == 3) {
        cell.textField.placeholder = @"password";
        cell.textField.secureTextEntry = YES;
        self.textFieldPassword = cell.textField;
    } else if (indexPath.row == 4) {
        cell.textField.placeholder = @"retype password";
        cell.textField.secureTextEntry = YES;
        self.textFieldRepassword = cell.textField;
    } else if (indexPath.row == 5) {
        cell.textField.placeholder = @"username";
        self.textFieldUsername = cell.textField;
        self.textFieldUsername.userInteractionEnabled = NO;
        self.textFieldUsername.text = sharedConnect.currentUser.userUsername;
    } else if (indexPath.row == 6) {
        cell.textField.placeholder = @"full name";
        self.textFieldFullName = cell.textField;
        self.textFieldFullName.text = sharedConnect.currentUser.userFullName;
    }
    return cell;
}

#pragma mark - Actions methods

- (void)cacelAction:(id)sender
{
    [self.tableView endEditing:NO];
    if (self.navigationController.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)selectAvatarButtonAction:(id)sender
{
    [self.tableView endEditing:NO];
    
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (void)saveChangesAction:(UIBarButtonItem *)barButtonItemSave
{
    if (!self.textFieldEmail.text.length) {
        [self showErrorWithMessage:@"Email is required."];
    } /*else if (!self.textFieldUsername.text.length) {
        [self showErrorWithMessage:@"Username is required."];
    }*/ else if (self.textFieldPassword.text.length && self.textFieldRepassword.text.length && !self.textFieldOldPassword.text.length) {
        [self showErrorWithMessage:@"Please enter your old password"];
    } else if (self.textFieldOldPassword.text.length && (!self.textFieldRepassword.text.length || !self.textFieldPassword.text.length)) {
        [self showErrorWithMessage:@"Please enter your new password"];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [self showErrorWithMessage:@"Password and repassword doesn't match."];
    } else if (![self isValidEmail:self.textFieldEmail.text UseHardFilter:YES]) {
        [self showErrorWithMessage:@"Email is not valid."];
    } else if (!self.textFieldFullName.text.length) {
        [self showErrorWithMessage:@"Full Name is required."];
    } else {
        NSString *password;
        if (self.textFieldPassword.text.length) {
            if (self.textFieldPassword.text.length < 4) {
                [self showErrorWithMessage:@"Your password needs to be at least 4 characters long."];
                return;
            } else {
                password = self.textFieldPassword.text;
            }
        }
        [hud show:YES];
        UIImage *image = self.imageReplaced ? self.avatarImageView.image : nil;
        [sharedConnect updateUserWithUserID:sharedConnect.currentUser.userID userType:WLIUserTypePerson userEmail:self.textFieldEmail.text oldPassword:self.textFieldOldPassword.text password:password userAvatar:image userFullName:self.textFieldFullName.text userInfo:@"" latitude:0 longitude:0 companyAddress:@"" companyPhone:@"" companyWeb:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            [self cacelAction:nil];
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

#pragma mark - Alert

- (void)showErrorWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageReplaced = YES;
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
