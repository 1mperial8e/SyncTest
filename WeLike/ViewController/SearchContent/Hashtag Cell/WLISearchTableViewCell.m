//
//  WLIHashtagTableViewCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 08/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISearchTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface WLISearchTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharpLabel;

@end

@implementation WLISearchTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.userImageView.layer.cornerRadius = CGRectGetHeight(self.userImageView.bounds) / 2;
    self.userImageView.layer.masksToBounds = YES;
}

- (void)prepareForReuse
{
    [self.userImageView cancelImageRequestOperation];
    self.userImageView.image = nil;
    self.hashtag = nil;
    self.user = nil;
}

#pragma mark - Accessors

- (void)setHashtag:(WLIHashtag *)hashtag
{
    _hashtag = hashtag;
    [self updateInfo];
}

- (void)setUser:(WLIUser *)user
{
    _user = user;
    [self updateInfo];
}

#pragma mark - Info

- (void)updateInfo
{
    BOOL isHashtag = self.hashtag ? YES : NO;
    self.usernameLabel.hidden = isHashtag;
    self.fullNameLabel.hidden = isHashtag;
    self.tagNameLabel.hidden = !isHashtag;
    self.sharpLabel.hidden = !isHashtag;
    self.tagCountLabel.hidden = !isHashtag;
    if (isHashtag) {
        self.userImageView.image = nil;
        self.tagNameLabel.text = self.hashtag.tagname;
        self.tagCountLabel.text = [NSString stringWithFormat:@"%zd", self.hashtag.tagcount];
    } else {
        self.usernameLabel.text = self.user.userUsername;
        self.fullNameLabel.text = self.user.userFullName;
        [self.userImageView setImageWithURL:[NSURL URLWithString:self.user.userAvatarThumbPath] placeholderImage:DefaultAvatar];
    }
}

@end
