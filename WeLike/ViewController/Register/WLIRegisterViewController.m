//
//  WLIRegisterViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIRegisterViewController.h"


@implementation WLIRegisterViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Register";
    
    self.buttonRegister.layer.cornerRadius = CGRectGetHeight(self.buttonRegister.frame)/2;

    [self.scrollViewRegister addSubview:self.viewContentRegister];
    [self adjustViewFrames];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Button methods

- (IBAction)buttonSelectAvatarTouchUpInside:(UIButton *)sender {
    
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender {

    if (!self.textFieldEmail.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (self.textFieldPassword.text.length < 4 || self.textFieldRepassword.text.length < 4) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is required. Your password should be at least 4 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password and repassword doesn't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldFullName.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Full Name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.imageViewAvatar.image) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Avatar image is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        
        [self.view endEditing:YES];
        [hud show:YES];
        
        [sharedConnect registerUserWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text email:self.textFieldEmail.text userAvatar:self.imageViewAvatar.image userType:WLIUserTypePerson userFullName:self.textFieldFullName.text userInfo:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else if (serverResponseCode == NO_CONNECTION) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (serverResponseCode == CONFLICT) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"User already exists. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
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


#pragma mark - Other methods

- (void)adjustViewFrames {
//    self.buttonRegister.frame = CGRectMake(self.buttonRegister.frame.origin.x, CGRectGetMaxY(self.textFieldFullName.frame) +20.0f, self.buttonRegister.frame.size.width, self.buttonRegister.frame.size.height);
//    self.viewContentRegister.frame = CGRectMake(self.viewContentRegister.frame.origin.x, self.viewContentRegister.frame.origin.y, self.viewContentRegister.frame.size.width, CGRectGetMaxY(self.buttonRegister.frame) +20.0f);
//    PNTToolbar *newToolbar = [PNTToolbar defaultToolbar];
//    newToolbar.mainScrollView = self.scrollViewRegister;
//    newToolbar.textFields = @[self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldUsername, self.textFieldFullName];
//    self.scrollViewRegister.contentSize = self.viewContentRegister.frame.size;
}


#pragma mark - NSNotification methods

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.origin.y - (64.0f + 44.0f);
    self.scrollViewRegister.frame = CGRectMake(0.0f, 44.0f, CGRectGetWidth(self.scrollViewRegister.frame), height);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGFloat height = CGRectGetHeight(self.view.frame);
    self.scrollViewRegister.frame = CGRectMake(0.0f, 44.0f, CGRectGetWidth(self.scrollViewRegister.frame), height);
}


- (void)dealloc {
    

}

@end
