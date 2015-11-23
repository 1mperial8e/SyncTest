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

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPostImage;

@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UILabel *labelComments;
@property (strong, nonatomic) IBOutlet UILabel *labelLikes;

@property (strong, nonatomic) WLIPost *post;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

@property (assign, nonatomic) BOOL showDeleteButton;
@property (assign, nonatomic) BOOL showFollowButton;

+ (CGSize)sizeWithPost:(WLIPost *)post withWidth:(CGFloat)width;

@end
