//
//  WLIMyDriveHeaderCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 28/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMyDriveHeaderCell.h"
#import "WLIEditProfileViewController.h"
#import "WLIConnect.h"
#import "WLIAppDelegate.h"
#import <MessageUI/MessageUI.h>

static CGFloat const LabelHeight = 22.f;

@interface WLIMyDriveHeaderCell () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelUserEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelUserTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelUserDepartment;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditProfile;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userTitleLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userDepartmentLabelHeight;

// MARK: Bottom container outlets
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@end

@implementation WLIMyDriveHeaderCell

#pragma mark - Object lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureViews];
    [self addGestures];
}

#pragma mark - Setup cell

- (void)configureViews
{
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height / 2;
    self.imageViewUser.layer.masksToBounds = YES;
    self.imageViewUser.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
    self.imageViewUser.layer.borderWidth = 3;
    
    self.buttonEditProfile.layer.cornerRadius = 5;
    self.buttonEditProfile.layer.masksToBounds = YES;
    self.buttonEditProfile.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.buttonEditProfile.layer.borderWidth = 1;
    
    self.followButton.layer.cornerRadius = 5;
    self.followButton.layer.borderWidth = 1;
}

- (void)addGestures
{
    UITapGestureRecognizer *followingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followingTap:)];
    UITapGestureRecognizer *followersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersTap:)];
	UITapGestureRecognizer *emailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailLabelTap:)];
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewTap:)];
    [self.followersLabel.superview addGestureRecognizer:followersTap];
    [self.followingLabel.superview addGestureRecognizer:followingTap];
	[self.labelUserEmail addGestureRecognizer:emailTap];
    [self.imageViewUser addGestureRecognizer:avatarTap];
}

#pragma mark - Public

- (void)updateRank:(NSInteger)rank forUsers:(NSInteger)users
{
    self.rankLabel.text = [NSString stringWithFormat:@"Rank: %zd/%zd", rank, users];
}

- (void)updatePoints:(NSInteger)points
{
    self.pointsCountLabel.text = [NSString stringWithFormat:@"%zd", points];
}

#pragma mark - Gestures

- (void)followersTap:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(showFollowersList)]) {
        [self.delegate showFollowersList];
    }
}

- (void)followingTap:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(showFollowingsList)]) {
        [self.delegate showFollowingsList];
    }
}

- (void)emailLabelTap:(UITapGestureRecognizer *)gesture
{
    [WLIUtils showCustomEmailControllerWithToRecepient:self.user.userEmail];
}

- (void)avatarImageViewTap:(UIGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(showAvatarForCell:)]) {
        [self.delegate showAvatarForCell:self];
    }
}

#pragma mark - Accessors

- (void)setUser:(WLIUser *)user
{
    _user = user;
    [self updateInfo];
}

#pragma mark - Cell methods

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
    self.imageViewUser.image = nil;
}

- (void)updateInfo
{
    if (self.user) {
        BOOL isMe = (self.user.userID == [WLIConnect sharedConnect].currentUser.userID);
        
        [self updateButtons:isMe];
        [self updateTextInfo];
        [self updateCountsInfo];
        [self updatePoints:self.user.points];

        if (self.user.userAvatarPath) {
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarThumbPath] placeholderImage:DefaultAvatar];
        }
        [self layoutIfNeeded];
    }
}

- (void)updateButtons:(BOOL)isMe
{
    self.followButton.hidden = isMe;
    self.buttonEditProfile.hidden = !isMe;
    self.followButton.selected = self.user.followingUser;
    if (self.followButton.selected) {
        self.followButton.backgroundColor = [UIColor colorWithRed:126/255.0 green:211/255.0 blue:33/255.0 alpha:1];
        self.followButton.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        self.followButton.backgroundColor = [UIColor whiteColor];
        self.followButton.layer.borderColor = [UIColor redColor].CGColor;
    }
}

- (void)updateTextInfo
{
    self.labelUserName.text = self.user.userFullName;
    self.labelUserEmail.text = self.user.userEmail;
    self.myGoalsTextView.text = [NSString stringWithFormat:@"%@", self.user.userInfo];
    if (self.user.userTitle.length > 0) {
        self.userTitleLabelHeight.constant = LabelHeight;
        self.labelUserTitle.text = self.user.userTitle;
    } else {
        self.userTitleLabelHeight.constant = 0;
    }
    if (self.user.userDepartment.length > 0) {
        self.userDepartmentLabelHeight.constant = LabelHeight;
        self.labelUserDepartment.text = self.user.userDepartment;
    } else {
        self.userDepartmentLabelHeight.constant = 0;
    }
}

- (void)updateCountsInfo
{
    self.likesCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.likesCount];
    self.postsCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.myPostsCount];
    self.followersCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.followersCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.followingCount];
}

#pragma mark - Actions

- (IBAction)editProficeAction:(id)sender
{
    WLIEditProfileViewController *editProfileVC = [WLIEditProfileViewController new];    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editProfileVC];
    navController.navigationBar.backgroundColor = [UIColor redColor];
    
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootVC presentViewController:navController animated:YES completion:nil];
}

- (IBAction)followButtonAction:(UIButton *)sender
{
	sender.userInteractionEnabled = NO;
	if (self.user.followingUser) {
		[[WLIConnect sharedConnect] removeFollowWithFollowID:self.user.userID onCompletion:^(ServerResponse serverResponseCode) {
			sender.userInteractionEnabled = YES;
		}];
	} else {
		[[WLIConnect sharedConnect] setFollowOnUserID:self.user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
			sender.userInteractionEnabled = YES;
		}];
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
	[controller dismissViewControllerAnimated:YES completion:^{
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}];
	switch (result) {
		case MFMailComposeResultFailed:
			NSLog(@"%@", error);
			break;
		default:
			break;
	}
}

@end
