//
//  WLIProfileViewController.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIConnect.h"
#import "UIImageView+AFNetworking.h"
#import "WLIViewController.h"

@interface WLIProfileViewController : WLIViewController <UIAlertViewDelegate> {
    WLIUser *_user;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewUserProfile;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelEmail;


@property (strong, nonatomic) IBOutlet UIView *viewLikes;
@property (strong, nonatomic) IBOutlet UILabel *labelLikesCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonLikes;

@property (strong, nonatomic) IBOutlet UIView *viewMyPosts;
@property (strong, nonatomic) IBOutlet UILabel *labelMyPostsCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonMyPosts;

@property (strong, nonatomic) IBOutlet UIView *viewFollowers;
@property (strong, nonatomic) IBOutlet UILabel *labelFollowersCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowers;

//@property (strong, nonatomic) IBOutlet UIView *viewFollowing;
//@property (strong, nonatomic) IBOutlet UILabel *labelFollowingCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonSettings;

@property (strong, nonatomic) IBOutlet UIButton *buttonLogout;

@property (strong, nonatomic, setter = setUser:) WLIUser *user;

- (void)barButtonItemEditTouchUpInside:(UIBarButtonItem*)barButtonItemEditProfile;
- (IBAction)buttonFollowToggleTouchUpInside:(id)sender;

- (IBAction)buttonLikesTouchUpInside:(id)sender;
- (IBAction)buttonMyPostsTouchUpInside:(id)sender;
- (IBAction)buttonFollowersTouchUpInside:(id)sender;
- (IBAction)buttonSettingsTouchUpInside:(id)sender;

- (IBAction)buttonLogoutTouchUpInside:(UIButton *)sender;

@end
