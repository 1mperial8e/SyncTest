//
//  WLICommentCell.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLICommentCell.h"
#import "UIImageView+AFNetworking.h"

static WLICommentCell *sharedCell = nil;

@interface WLICommentCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelTimeAgo;
@property (strong, nonatomic) IBOutlet UILabel *labelCommentText;

@end

@implementation WLICommentCell

#pragma mark - Object lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height / 2;
    self.imageViewUser.layer.masksToBounds = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
}

#pragma mark - Accessors

- (void)setComment:(WLIComment *)comment
{
    _comment = comment;
    [self updateInfo];
}

#pragma mark - Update

- (void)updateInfo
{
    if (self.comment && ![self.comment isEqual:[NSNull null]]) {
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.comment.user.userAvatarPath] placeholderImage:DefaultAvatar];
        
        self.labelUsername.text = self.comment.user.userFullName;
        self.labelTimeAgo.text = self.comment.commentTimeAgo;
        
        self.labelCommentText.text = self.comment.commentText;
        CGSize labelSize = [self.labelCommentText sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 56, MAXFLOAT)];
        CGRect frame = self.labelCommentText.frame;
        frame.size = labelSize;
        self.labelCommentText.frame = frame;
    }
}

#pragma mark - Actions

- (IBAction)buttonUserTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.comment.user sender:self];
    }
}

#pragma mark - Static

+ (CGSize)sizeWithComment:(WLIComment *)comment
{
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLICommentCell" owner:nil options:nil] lastObject];
    }
    sharedCell.comment = comment;
    [sharedCell updateInfo];
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(sharedCell.labelCommentText.frame) + 10.0f);
}

@end
