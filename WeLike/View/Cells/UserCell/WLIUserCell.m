//
//  WLIUserCell.m
//  WeLike
//
//  Created by Planet 1107 on 07/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLIUserCell.h"
#import "UIImageView+AFNetworking.h"
#import "WLIConnect.h"

@interface WLIUserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUserImage;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;

@end

@implementation WLIUserCell

#pragma mark - Object lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageViewUserImage.layer.cornerRadius = self.imageViewUserImage.frame.size.height / 2;
    self.imageViewUserImage.layer.masksToBounds = YES;
    self.imageViewUserImage.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
    self.imageViewUserImage.layer.borderWidth = 2.f;
}

#pragma mark - Accessors

- (void)setUser:(WLIUser *)user
{
    _user = user;
    [self setupCell];
}

#pragma mark - Configure cell

- (void)setupCell
{
    [self.imageViewUserImage setImageWithURL:[NSURL URLWithString:self.user.userAvatarThumbPath] placeholderImage:DefaultAvatar];
    self.labelUserName.text = self.user.userUsername;
    self.buttonFollow.selected = self.user.followingUser;
    self.buttonFollow.hidden = (self.user.userID == [WLIConnect sharedConnect].currentUser.userID);
}

#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender
{    
    if ([self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
        [self.delegate showUser:self.user userID:self.user.userID sender:self];
    }
}

- (IBAction)buttonFollowTouchUpInside:(UIButton *)sender
{
    if (self.user.followingUser) {
        if ([self.delegate respondsToSelector:@selector(unfollowUser:sender:)]) {
            [self.delegate unfollowUser:self.user sender:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(followUser:sender:)]) {
            [self.delegate followUser:self.user sender:self];
        }
    }
}

@end
