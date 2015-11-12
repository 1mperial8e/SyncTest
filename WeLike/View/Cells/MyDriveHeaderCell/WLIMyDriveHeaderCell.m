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

@interface WLIMyDriveHeaderCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelUserEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonEditProfile;

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
    self.imageViewUser.layer.borderColor = [UIColor redColor].CGColor;
    self.imageViewUser.layer.borderWidth = 3;
    
    self.buttonEditProfile.layer.cornerRadius = 5;
    self.buttonEditProfile.layer.masksToBounds = YES;
    self.buttonEditProfile.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.buttonEditProfile.layer.borderWidth = 1;
}

- (void)addGestures
{
    UITapGestureRecognizer *followingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followingTap:)];
    UITapGestureRecognizer *followersTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersTap:)];
    [self.followersLabel.superview addGestureRecognizer:followersTap];
    [self.followingLabel.superview addGestureRecognizer:followingTap];
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
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath] placeholderImage:DefaultAvatar];
        self.labelUserName.text = self.user.userFullName;
        self.labelUserEmail.text = self.user.userEmail;
        
        self.likesCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.likesCount];
        self.postsCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.myPostsCount];
        self.followersCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.followersCount];
        self.followingCountLabel.text = [NSString stringWithFormat:@"%zd", self.user.followingCount];
        NSInteger points = self.user.likesCount + self.user.myPostsCount + self.user.followersCount + self.user.followingCount;
        self.pointsCountLabel.text = [NSString stringWithFormat:@"%zd", points];
    }
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

@end
