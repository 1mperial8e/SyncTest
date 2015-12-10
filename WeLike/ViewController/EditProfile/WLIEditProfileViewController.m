//
//  WLIEditProfileViewController.m
//  WeLike
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIEditProfileViewController.h"
#import "WLIChangePasswordViewController.h"

// Cells
#import "WLIRegisterAvatarTableViewCell.h"
#import "WLIRegisterTableViewCell.h"
#import "WLIMyGoalsTableViewCell.h"
#import "WLIChangePasswordTableViewCell.h"

// Models
#import "WLIAppDelegate.h"

@interface WLIEditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UITextField *textFieldEmail;
@property (weak, nonatomic) UITextField *textFieldUsername;
@property (weak, nonatomic) UITextField *textFieldFullName;
@property (weak, nonatomic) UITextView *textViewMyGoals;

@property (weak, nonatomic) UIImageView *avatarImageView;
@property (nonatomic) CGSize myGoalsTextViewContentSize;

@property (assign, nonatomic) BOOL imageReplaced;

@end

@implementation WLIEditProfileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Edit Profile";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;    
    [self.tableView registerNib:WLIRegisterAvatarTableViewCell.nib forCellReuseIdentifier:WLIRegisterAvatarTableViewCell.ID];
    [self.tableView registerNib:WLIRegisterTableViewCell.nib forCellReuseIdentifier:WLIRegisterTableViewCell.ID];
	[self.tableView registerNib:WLIMyGoalsTableViewCell.nib forCellReuseIdentifier:WLIMyGoalsTableViewCell.ID];
    [self.tableView registerNib:WLIChangePasswordTableViewCell.nib forCellReuseIdentifier:WLIChangePasswordTableViewCell.ID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveChangesAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cacelAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.textFieldEmail && self.textFieldUsername && self.textFieldFullName) {
        toolbar.mainScrollView = self.tableView;
        toolbar.textFields = @[/*self.textFieldEmail,*/ self.textFieldUsername,  self.textFieldFullName, self.textViewMyGoals];
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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self avatarCellForIndexPath:indexPath];
	} else if (indexPath.row == 4) {
		WLIMyGoalsTableViewCell *myGoalsCell = [tableView dequeueReusableCellWithIdentifier:WLIMyGoalsTableViewCell.ID forIndexPath:indexPath];
		if (sharedConnect.currentUser.userInfo.length) {
			myGoalsCell.textView.text = sharedConnect.currentUser.userInfo;
		} else {
			myGoalsCell.textView.text = MyDriveGoalsPlaceholder;
		}
		self.textViewMyGoals = myGoalsCell.textView;
		self.textViewMyGoals.delegate = self;
		self.myGoalsTextViewContentSize = myGoalsCell.textView.contentSize;
		cell = myGoalsCell;
	} else if (indexPath.row == 5) {
        WLIChangePasswordTableViewCell *passCell = [tableView dequeueReusableCellWithIdentifier:WLIChangePasswordTableViewCell.ID forIndexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        passCell.changePasswordHandler = ^{
            WLIChangePasswordViewController *changePassController = [WLIChangePasswordViewController new];
            [weakSelf.navigationController pushViewController:changePassController animated:YES];
        };
        cell = passCell;
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
    } else if (indexPath.row == 4) 	{
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WLIMyGoalsTableViewCell" owner:self options:nil];
		WLIMyGoalsTableViewCell *cell  = [topLevelObjects objectAtIndex:0];
		cell.textView.text = self.textViewMyGoals.text;
		CGFloat height = ceilf([cell.textView sizeThatFits:CGSizeMake(cell.textView.frame.size.width, MAXFLOAT)].height);
		return height + 20;
	}
    return heigh;
}

#pragma mark - ConfigureCell

- (UITableViewCell *)avatarCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIRegisterAvatarTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLIRegisterAvatarTableViewCell.ID forIndexPath:indexPath];
    self.avatarImageView = cell.avatarImageView;
    
    __block NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sharedConnect.currentUser.userAvatarThumbPath]];
    __weak typeof(self) weakSelf = self;
    [self.avatarImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        [weakSelf.avatarImageView setImageWithURL:[NSURL URLWithString:sharedConnect.currentUser.userAvatarPath]];
    } failure:nil];
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
        self.textFieldEmail.userInteractionEnabled =NO;
        self.textFieldEmail.text = sharedConnect.currentUser.userEmail;
    } else if (indexPath.row == 2) {
        cell.textField.placeholder = @"username";
        self.textFieldUsername = cell.textField;
        self.textFieldUsername.userInteractionEnabled =YES;
        self.textFieldUsername.text = sharedConnect.currentUser.userUsername;
    } else if (indexPath.row == 3) {
        cell.textField.placeholder = @"full name";
        self.textFieldFullName = cell.textField;
        self.textFieldFullName.text = sharedConnect.currentUser.userFullName;
	}
    return cell;
}

#pragma mark - Actions methods

- (void)cacelAction:(id)sender
{
    [self.avatarImageView cancelImageRequestOperation];
    [self.tableView endEditing:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    } else if (!self.textFieldUsername.text.length) {
        [self showErrorWithMessage:@"Username is required."];
    } else if (![WLIUtils isValidUserName:self.textFieldUsername.text]) {
       [self showErrorWithMessage:@"Username isn't valid."];
    } else if (!self.textFieldFullName.text.length) {
        [self showErrorWithMessage:@"Full Name is required."];
    } else {
        [hud show:YES];
        __weak typeof(self) weakSelf = self;
        UIImage *image = self.imageReplaced ? self.avatarImageView.image : nil;
        NSString *aboutText = self.textViewMyGoals.text;
        if ([aboutText isEqualToString:MyDriveGoalsPlaceholder]) {
            aboutText = @"";
        }
        [sharedConnect updateUserWithUserID:sharedConnect.currentUser.userID userType:WLIUserTypePerson userUsername:self.textFieldUsername.text userAvatar:image userFullName:self.textFieldFullName.text userInfo:aboutText latitude:0 longitude:0 companyAddress:@"" companyPhone:@"" companyWeb:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode != OK) {
                [weakSelf showErrorWithMessage:@"Something went wrong. Please try again."];
            } else {
                [weakSelf cacelAction:nil];
            }
        }];
    }
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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
    NSRange placeholderRange = NSMakeRange(0, MyDriveGoalsPlaceholder.length);
    if (NSIntersectionRange(placeholderRange, range).length) {
        return NO;
    }
	if ([string isEqualToString:@"\n"]) {
		[[self view] endEditing:YES];
		return  NO;
	}
    NSString *newText = [self.textViewMyGoals.text stringByReplacingCharactersInRange:range withString:string];
	return newText.length < 255;
}

- (void)textViewDidChange:(UITextView *)textView
{
	CGFloat height = ceilf([textView sizeThatFits:textView.frame.size].height);
	if (self.myGoalsTextViewContentSize.height != height) {
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
		self.myGoalsTextViewContentSize = textView.contentSize;
	}
}

@end
