//
//  WLILikeCell.m
//  WeLike
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLILikeCell.h"
#import "UIImageView+AFNetworking.h"

static WLILikeCell *sharedCell = nil;

@interface WLILikeCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;

@end

@implementation WLILikeCell

#pragma mark - Object lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height/2;
    self.imageViewUser.layer.masksToBounds = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
}

#pragma mark - Accessors

- (void)setLike:(WLILike *)like
{
    _like = like;
    [self updateInfo];
}

#pragma mark - Static

+ (CGSize)sizeWithLike:(WLILike *)like
{
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLILikeCell" owner:nil options:nil] lastObject];
    }
    sharedCell.like = like;
    return sharedCell.frame.size;
}

#pragma mark - Info

- (void)updateInfo
{
    if (self.like) {
        NSURL *userImageURL = [NSURL URLWithString:self.like.user.userAvatarPath];
        [self.imageViewUser setImageWithURL:userImageURL placeholderImage:DefaultAvatar];
        self.labelUsername.text = self.like.user.userFullName;
    }
}

#pragma mark - Actions

- (IBAction)buttonUserTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.like.user sender:self];
    }
}

@end
