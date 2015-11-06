//
//  WLIEditProfileViewController.m
//  WeLike
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIEditProfileViewController.h"
#import "WLIAppDelegate.h"

@implementation WLIEditProfileViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Edit Profile";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(barButtonItemSaveTouchUpInside:)];
    if (self.navigationController.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cacelAction:)];
    }

    self.scrollViewEditProfile.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.scrollViewEditProfile addSubview:self.viewContentEditProfile];
    toolbar.mainScrollView = self.scrollViewEditProfile;
    
    self.viewContentEditProfile.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(self.textFieldFullName.frame) +20.0f);
    toolbar.textFields = @[self.textFieldUsername, self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldFullName];
    
    self.scrollViewEditProfile.contentSize = self.viewContentEditProfile.frame.size;
    
    self.imageViewAvatar.layer.cornerRadius = CGRectGetHeight(self.imageViewAvatar.frame) / 2;
    self.imageViewAvatar.layer.masksToBounds = YES;
    NSURL *avatarURL = [NSURL URLWithString:sharedConnect.currentUser.userAvatarPath];
    [self.imageViewAvatar setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatar-empty"]];
    
    self.textFieldUsername.text = sharedConnect.currentUser.userUsername;
    self.textFieldEmail.text = sharedConnect.currentUser.userEmail;
    self.textFieldFullName.text = sharedConnect.currentUser.userFullName;
    self.textFieldUsername.text = sharedConnect.currentUser.userUsername;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions methods

- (void)cacelAction:(id)sender
{
    if (self.navigationController.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)barButtonItemSaveTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
    
    if (!self.textFieldEmail.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password and repassword doesn't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldFullName.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Full Name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else
//    if (!self.imageViewAvatar.image) {
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Avatar image is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    } else
    {
        
    NSString *password;
    if (self.textFieldPassword.text.length) {
        if (self.textFieldPassword.text.length < 4) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your password needs to be at least 4 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        } else {
            password = self.textFieldPassword.text;
        }
    }
    

        [hud show:YES];
        UIImage *image;
        if (imageReplaced) {
            image = self.imageViewAvatar.image;
        }
        
        [sharedConnect updateUserWithUserID:sharedConnect.currentUser.userID userType:WLIUserTypePerson userEmail:self.textFieldEmail.text password:password userAvatar:image userFullName:self.textFieldFullName.text userInfo:@"" latitude:0 longitude:0 companyAddress:@"" companyPhone:@"" companyWeb:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            [self cacelAction:nil];
        }];
    }
}

- (IBAction)buttonSelectAvatarTouchUpInside:(UIButton *)sender
{
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showFromTabBar:appDelegate.tabBarController.tabBar];
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    imageReplaced = YES;
    self.imageViewAvatar.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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

#pragma mark - Keyboard methods

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.size.height + 5;
    self.scrollViewEditProfile.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.scrollViewEditProfile.contentInset = UIEdgeInsetsZero;
}

@end
