//
//  WLILoginViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLILoginViewController.h"
#import "WLIAppDelegate.h"
#import "WLITimelineViewController.h"

@implementation WLILoginViewController


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
    self.title = @"Login";
    
    self.buttonLogin.layer.cornerRadius = CGRectGetHeight(self.buttonLogin.frame)/2;

    [self.scrollViewLogin addSubview:self.viewContentLogin];
    self.scrollViewLogin.contentSize = self.viewContentLogin.frame.size;
    toolbar.mainScrollView = self.scrollViewLogin;
    toolbar.textFields = @[self.textFieldUsername, self.textFieldPassword];
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

- (IBAction)buttonRegisterTouchUpInside:(id)sender {
    
    if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldPassword.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [self.view endEditing:YES];
        [hud show:YES];
        [sharedConnect loginUserWithUsername:self.textFieldUsername.text andPassword:self.textFieldPassword.text onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
                [self dismissViewControllerAnimated:YES completion:^{
                    WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
                    WLITimelineViewController *timelineViewController = (WLITimelineViewController *)[appDelegate.tabBarController.viewControllers[0] topViewController];
                    [timelineViewController reloadData:YES];
                }];
            } else if (serverResponseCode == NO_CONNECTION) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (serverResponseCode == NOT_FOUND) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong username. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (serverResponseCode == UNAUTHORIZED) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong password. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}


#pragma mark - NSNotification methods

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.origin.y - 64.0f;
    self.scrollViewLogin.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.scrollViewLogin.frame), height);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGFloat height = CGRectGetHeight(self.view.frame);
    self.scrollViewLogin.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.scrollViewLogin.frame), height);
}

@end
