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
#import "WLIEditProfileTableViewCell.h"
#import "WLIMyGoalsTableViewCell.h"
#import "WLIChangePasswordTableViewCell.h"

// Models
#import "WLIAppDelegate.h"

static CGFloat const AvatarCellHeigth = 130.0f;
static CGFloat const ButtonCellHeigth = 50.0f;
static CGFloat const TextFieldCellHeigth = 60.0f;

@interface WLIEditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UITextField *textFieldEmail;
@property (weak, nonatomic) UITextField *textFieldUsername;
@property (weak, nonatomic) UITextField *textFieldFullName;
@property (weak, nonatomic) UITextField *textFieldTitle;
@property (weak, nonatomic) UITextField *textFieldDepartment;
@property (weak, nonatomic) UITextView *textViewMyGoals;

@property (weak, nonatomic) UIImageView *avatarImageView;

@property (assign, nonatomic) BOOL imageReplaced;

@end

@implementation WLIEditProfileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupNavigationItem];
    [self setupTableView];
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
    
    if (self.textFieldEmail && self.textFieldUsername && self.textFieldFullName) {
        toolbar.mainScrollView = self.tableView;
        toolbar.textFields = @[self.textFieldUsername, self.textFieldFullName, /*self.textFieldTitle, self.textFieldDepartment, */self.textViewMyGoals];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Setup

- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [self.tableView registerNib:WLIRegisterAvatarTableViewCell.nib forCellReuseIdentifier:WLIRegisterAvatarTableViewCell.ID];
    [self.tableView registerNib:WLIEditProfileTableViewCell.nib forCellReuseIdentifier:WLIEditProfileTableViewCell.ID];
    [self.tableView registerNib:WLIMyGoalsTableViewCell.nib forCellReuseIdentifier:WLIMyGoalsTableViewCell.ID];
    [self.tableView registerNib:WLIChangePasswordTableViewCell.nib forCellReuseIdentifier:WLIChangePasswordTableViewCell.ID];
}

- (void)setupNavigationItem
{
    self.navigationItem.title = @"Edit Profile";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveChangesAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cacelAction:)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self avatarCellForIndexPath:indexPath];
	} else if (indexPath.row == 6) {
        cell = [self myGoalsCellForIndexPath:indexPath];
	} else if (indexPath.row == 7 || indexPath.row == 8) {
        cell = [self buttonCellForIndexPath:indexPath];
    } else {
        cell = [self dataFieldCellForIndexPath:indexPath];
    }
	[cell setClipsToBounds:YES];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = TextFieldCellHeigth;
    if (indexPath.row == 0) {
        height = AvatarCellHeigth;
    } else if (indexPath.row == 4 || indexPath.row == 5) 	{
		height = 0;
	} else if (indexPath.row == 6) 	{
		height = [self textViewCellHeight];
	} else if (indexPath.row == 7 || indexPath.row == 8) {
        height = ButtonCellHeigth;
    }
    return height;
}

- (CGFloat)textViewCellHeight
{
    static WLIMyGoalsTableViewCell *cell;
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"WLIMyGoalsTableViewCell" owner:nil options:nil].firstObject;;
    }
    cell.textView.text = self.textViewMyGoals.text;
    CGFloat height = ceilf([cell.textView sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, MAXFLOAT)].height);
    return height + 33.f;
}

#pragma mark - ConfigureCell

- (UITableViewCell *)avatarCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIRegisterAvatarTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLIRegisterAvatarTableViewCell.ID forIndexPath:indexPath];
    self.avatarImageView = cell.avatarImageView;
    
    __block NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sharedConnect.currentUser.userAvatarThumbPath]];
    __weak typeof(self) weakSelf = self;
    [self.avatarImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        weakSelf.avatarImageView.image = image;
        [weakSelf.avatarImageView setImageWithURL:[NSURL URLWithString:sharedConnect.currentUser.userAvatarPath]];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        [weakSelf.avatarImageView setImageWithURL:[NSURL URLWithString:sharedConnect.currentUser.userAvatarPath]];
    }];
    
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(cell.avatarImageView.bounds) / 2;
    self.avatarImageView.layer.masksToBounds = YES;
    
    [cell.chooseAvatarButton addTarget:self action:@selector(selectAvatarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (UITableViewCell *)dataFieldCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIEditProfileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLIEditProfileTableViewCell.ID forIndexPath:indexPath];
    if (indexPath.row == 1) {
        cell.label.text = @"E-mail address";
        cell.textField.placeholder = @"Email Address";
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        self.textFieldEmail = cell.textField;
        self.textFieldEmail.userInteractionEnabled =NO;
        self.textFieldEmail.text = sharedConnect.currentUser.userEmail;
    } else if (indexPath.row == 2) {
        cell.label.text = @"Username";
        cell.textField.placeholder = @"Username";
        self.textFieldUsername = cell.textField;
        self.textFieldUsername.userInteractionEnabled =YES;
        self.textFieldUsername.text = sharedConnect.currentUser.userUsername;
    } else if (indexPath.row == 3) {
        cell.label.text = @"Full name";
        cell.textField.placeholder = @"Full name";
        self.textFieldFullName = cell.textField;
        self.textFieldFullName.text = sharedConnect.currentUser.userFullName;
	} else if (indexPath.row == 4) {
		cell.label.text = @"Title";
		cell.textField.placeholder = @"Title";
		self.textFieldTitle = cell.textField;
		self.textFieldTitle.text = sharedConnect.currentUser.userTitle;
	} else if (indexPath.row == 5) {
		cell.label.text = @"Department";
		cell.textField.placeholder = @"Department";
		self.textFieldDepartment = cell.textField;
		self.textFieldDepartment.text = sharedConnect.currentUser.userDepartment;
	}
    return cell;
}

- (UITableViewCell *)buttonCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIChangePasswordTableViewCell *passCell = [self.tableView dequeueReusableCellWithIdentifier:WLIChangePasswordTableViewCell.ID forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 7) {
        passCell.changePasswordHandler = ^{
            __strong typeof(self) strongSelf = weakSelf;
            WLIChangePasswordViewController *changePassController = [WLIChangePasswordViewController new];
            [strongSelf.navigationController pushViewController:changePassController animated:YES];
        };
    } else if (indexPath.row == 8) {
        [passCell.changePasswordButton setTitle:@"Logout" forState:UIControlStateNormal];
        passCell.changePasswordHandler = ^{
            __strong typeof(self) strongSelf = weakSelf;
            [[WLIConnect sharedConnect] logout];
            [strongSelf dismissViewControllerAnimated:NO completion:nil];
            WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.tabBarController.selectedIndex = 0;
            [appDelegate.tabBarController showUI];
        };
    }
    return passCell;
}

- (UITableViewCell *)myGoalsCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIMyGoalsTableViewCell *myGoalsCell = [self.tableView dequeueReusableCellWithIdentifier:WLIMyGoalsTableViewCell.ID forIndexPath:indexPath];
    if (sharedConnect.currentUser.userInfo.length) {
        myGoalsCell.textView.text = sharedConnect.currentUser.userInfo;
    } else {
        myGoalsCell.textView.text = MyDriveGoalsPlaceholder;
    }
    self.textViewMyGoals = myGoalsCell.textView;
    self.textViewMyGoals.delegate = self;
    return myGoalsCell;
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
        [self updateProfile];
    }
}

- (void)updateProfile
{
    [hud show:YES];
    __weak typeof(self) weakSelf = self;
    UIImage *image = self.imageReplaced ? self.avatarImageView.image : nil;
    NSString *aboutText = self.textViewMyGoals.text;
    if ([aboutText isEqualToString:MyDriveGoalsPlaceholder]) {
        aboutText = @"";
    }
	[sharedConnect updateUserWithUserID:sharedConnect.currentUser.userID userType:WLIUserTypePerson userUsername:self.textFieldUsername.text userAvatar:image userFullName:self.textFieldFullName.text userTitle:self.textFieldTitle.text userDepartment:self.textFieldDepartment.text userInfo:aboutText latitude:0 longitude:0 companyAddress:@"" companyPhone:@"" companyWeb:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
        [hud hide:YES];
        if (serverResponseCode != OK) {
            [weakSelf showErrorWithMessage:@"Something went wrong. Please try again."];
        } else {
            [weakSelf cacelAction:nil];
        }
    }];
}

#pragma mark - Alert

- (void)showErrorWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)showMediaAccessAlert:(NSString *)alertMessage
{
	UIAlertView *accessAlert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
	[accessAlert show];
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
	__weak typeof(self) weakSelf = self;
	
	void (^getContentBlock)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType sourceType){
		AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
		if (status == AVAuthorizationStatusAuthorized || status == ALAuthorizationStatusNotDetermined) {
			[weakSelf getContentWithSourceType:sourceType];
		} else {
			if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
				[weakSelf showMediaAccessAlert:@"Please provide access to your library in settings" ];
			} else {
				[weakSelf showMediaAccessAlert:@"Please provide access to your camera in settings" ];
			}
		}
	};
	
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]) {
		getContentBlock(UIImagePickerControllerSourceTypePhotoLibrary);
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
		getContentBlock(UIImagePickerControllerSourceTypeCamera);
    }
}

#pragma mark - Add content

- (void)getContentWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
	if ((sourceType == UIImagePickerControllerSourceTypeCamera) && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Camera Available." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		return;
	}
	UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
	pickerController.delegate = self;
	pickerController.sourceType = sourceType;
	pickerController.allowsEditing = YES;
	[self presentViewController:pickerController animated:YES completion:nil];
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
    if (range.location <= MyDriveGoalsPlaceholder.length - 1) {
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
	CGFloat height = ceil([textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.frame), MAXFLOAT)].height + 0.5);
	if (textView.contentSize.height > height + 1 || textView.contentSize.height < height - 1) {
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
        
        CGRect textViewRect = [self.tableView convertRect:textView.frame fromView:textView.superview];
        textViewRect.origin.y += 5;
        [self.tableView scrollRectToVisible:textViewRect animated:YES];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex) {
		NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		[[UIApplication sharedApplication] openURL:url];
	}
}


@end
