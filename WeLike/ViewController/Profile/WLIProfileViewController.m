//
//  WLIProfileViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIProfileViewController.h"
#import "WLIEditProfileViewController.h"
#import "GlobalDefines.h"
#import "WLIFollowingViewController.h"
#import "WLIFollowersViewController.h"
#import "WLISearchViewController.h"
#import "WLIWelcomeViewController.h"
#import "WLIAppDelegate.h"

@implementation WLIProfileViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Profile";
        NSLog(@"Profil 1");
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    NSLog(@"Profil 2");
    
    [super viewDidLoad];
    
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.width/2;
    self.imageViewUser.layer.borderWidth = 4.0f;
    self.imageViewUser.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    self.imageViewUser.layer.masksToBounds = YES;
    
    self.buttonFollow.layer.cornerRadius = self.buttonFollow.frame.size.width/2;
    self.buttonFollow.layer.borderWidth = 4.0f;
    self.buttonFollow.layer.borderColor = [[UIColor whiteColor] CGColor]; // [[UIColor colorWithRed:255/255.0f green:80/255.0f blue:70/255.0f alpha:1.0f] CGColor];
    self.buttonFollow.layer.masksToBounds = YES;
    
    self.buttonLogout.layer.cornerRadius = CGRectGetHeight(self.buttonLogout.frame)/2;
    
    if (self.user.userID == [WLIConnect sharedConnect].currentUser.userID) {
        self.buttonFollow.alpha = 0.0f;
    } else {
        if (self.user.followingUser) {
            [self.buttonFollow setTitle:@"-" forState:UIControlStateNormal];
        } else {
            [self.buttonFollow setTitle:@"+" forState:UIControlStateNormal];
        }
    }

    if (self.user == [WLIConnect sharedConnect].currentUser) {
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.adjustsImageWhenHighlighted = NO;
        editButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
        [editButton setImage:[UIImage imageNamed:@"nav-btn-edit"] forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(barButtonItemEditTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        self.scrollViewUserProfile.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.buttonLogout.frame) +20.0f);
    } else {
        self.buttonLogout.alpha = 0.0f;
        self.scrollViewUserProfile.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.viewFollowers.frame) +20.0f);
    }
    NSLog(@"Profil 3");
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self updateFramesAndDataWithDownloads:YES];
}

- (WLIUser*)user {
    
    if (_user) {
        return _user;
    } else {
        return [WLIConnect sharedConnect].currentUser;
    }
}

- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    self.labelName.text = self.user.userFullName;
    self.labelEmail.text = self.user.userEmail;
    
    
    
    if (self.user.followingUser) {
        [self.buttonFollow setTitle:@"-" forState:UIControlStateNormal];
    } else {
        [self.buttonFollow setTitle:@"+" forState:UIControlStateNormal];
    }
    self.labelFollowersCount.text = [NSString stringWithFormat:@"%zd", self.user.followersCount];
    self.labelLikesCount.text = [NSString stringWithFormat:@"%zd", self.user.likesCount];
    self.labelMyPostsCount.text = [NSString stringWithFormat:@"%zd", self.user.myPostsCount];

    
    if (downloads) {
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath] placeholderImage:DefaultAvatar];
        
        [sharedConnect userWithUserID:self.user.userID onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            _user = user;
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath] placeholderImage:DefaultAvatar];
            self.labelName.text = self.user.userFullName;
            self.labelEmail.text = self.user.userEmail;
            if (self.user.followingUser) {
                [self.buttonFollow setTitle:@"-" forState:UIControlStateNormal];
            } else {
                [self.buttonFollow setTitle:@"+" forState:UIControlStateNormal];
            }
            self.labelFollowersCount.text = [NSString stringWithFormat:@"%zd", self.user.followersCount];
            self.labelLikesCount.text = [NSString stringWithFormat:@"%zd", self.user.likesCount];
            self.labelMyPostsCount.text = [NSString stringWithFormat:@"%zd", self.user.myPostsCount];
        }];
    }
}


#pragma mark - Buttons methods

- (void)barButtonItemEditTouchUpInside:(UIBarButtonItem*)barButtonItemEditProfile
{
    
    WLIEditProfileViewController *editProfileViewController = [[WLIEditProfileViewController alloc] initWithNibName:@"WLIEditProfileViewController" bundle:nil];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

- (IBAction)buttonFollowToggleTouchUpInside:(id)sender
{
    
    if (self.user.followingUser) {
        self.user.followingUser = NO;
        self.user.followersCount--;
        [self updateFramesAndDataWithDownloads:NO];
        [sharedConnect removeFollowWithFollowID:self.user.userID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                self.user.followingUser = YES;
                self.user.followersCount++;
                [self updateFramesAndDataWithDownloads:NO];
                [[[UIAlertView alloc] initWithTitle:@"Following" message:[NSString stringWithFormat:@"An error occured, you are still following %@", self.user.userFullName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    } else {
        self.user.followingUser = YES;
        self.user.followersCount++;
        [self updateFramesAndDataWithDownloads:NO];
        [sharedConnect setFollowOnUserID:self.user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                self.user.followingUser = NO;
                self.user.followersCount--;
                [self updateFramesAndDataWithDownloads:NO];
                [[[UIAlertView alloc] initWithTitle:@"Not Following" message:[NSString stringWithFormat:@"An error occured, you are still following %@", self.user.userFullName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

- (IBAction)buttonLikesTouchUpInside:(id)sender
{
    if (self.user.likesCount > 0)
    {
        
    }
}

- (IBAction)buttonMyPostsTouchUpInside:(id)sender
{
    if (self.user.myPostsCount > 0)
    {
        
    }
}

- (IBAction)buttonFollowersTouchUpInside:(id)sender
{
    if (self.user.likesCount > 0)
    {
        WLIFollowersViewController *followersViewController = [[WLIFollowersViewController alloc] initWithNibName:@"WLIFollowersViewController" bundle:nil];
        followersViewController.user = self.user;
        [self.navigationController pushViewController:followersViewController animated:YES];
    }
}

- (IBAction)buttonSettingsTouchUpInside:(id)sender
{
    
}


//- (IBAction)buttonFollowingTouchUpInside:(id)sender {
//    
//    WLIFollowingViewController *followingViewController = [[WLIFollowingViewController alloc] initWithNibName:@"WLIFollowingViewController" bundle:nil];
//    followingViewController.user = self.user;
//    [self.navigationController pushViewController:followingViewController animated:YES];
//}


//- (IBAction)buttonSearchUsersTouchUpInside:(id)sender {
//    
//    WLISearchViewController *searchViewController = [[WLISearchViewController alloc] initWithNibName:@"WLISearchViewController" bundle:nil];
//    [self.navigationController pushViewController:searchViewController animated:YES];
//}

- (IBAction)buttonLogoutTouchUpInside:(UIButton *)sender {
    
    [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure that you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"Logout"] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [[WLIConnect sharedConnect] logout];
        WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate createViewHierarchy];
    }
}

@end
