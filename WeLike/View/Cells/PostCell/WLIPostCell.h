//
//  WLIPostCell.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITableViewCell.h"
#import "WLIPost.h"
#import "UIImageView+AFNetworking.h"

@class WLIPostCell;

@interface WLIPostCell : WLITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPostImage;
@property (weak, nonatomic) IBOutlet UIButton *buttonFollow;
@property (weak, nonatomic) IBOutlet UIButton *buttonLike;
@property (weak, nonatomic) IBOutlet UIView *commentsContainer;

@property (weak, nonatomic) WLIPost *post;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

@property (assign, nonatomic) BOOL showDeleteButton;
@property (assign, nonatomic) BOOL showFollowButton;

@property (strong, nonatomic) UIImage *originalImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageActivityIndicator;

+ (CGSize)sizeWithPost:(WLIPost *)post withWidth:(CGFloat)width;

- (void)updateLikesInfo;
- (void)updateCommentsInfo;
- (void)blockUserInteraction;

@end
