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
#import <MediaPlayer/MediaPlayer.h>

@class WLIPostCell;

@interface WLIPostCell : WLITableViewCell {
    
    CGRect frameDefaultLabelPostTitle;
    CGRect frameDefaultLabelPostText;
    CGRect frameDefaultImageViewPost;
    MPMoviePlayerViewController *movieController;
    
    IBOutlet UIView *topView;
    IBOutlet UIView *middleView;
    IBOutlet UIView *bottomView;
    
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet UILabel *labelTimeAgo;
@property (strong, nonatomic) IBOutlet UILabel *labelPostTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelPostText;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPostImage;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UILabel *labelComments;
//@property (strong, nonatomic) IBOutlet UIButton *buttonLikes;
@property (strong, nonatomic) IBOutlet UILabel *labelLikes;
@property (strong, nonatomic) IBOutlet UIButton *buttonVideo;

@property (strong, nonatomic) IBOutlet UIButton *buttonShare;
@property (strong, nonatomic) IBOutlet UIButton *buttonMore;

@property (strong, nonatomic) IBOutlet UIButton *buttonCatMarket;
@property (strong, nonatomic) IBOutlet UIButton *buttonCatCustomer;
@property (strong, nonatomic) IBOutlet UIButton *buttonCatCapabilities;
@property (strong, nonatomic) IBOutlet UIButton *buttonCatPeople;


@property (strong, nonatomic) WLIPost *post;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

- (IBAction)buttonUserTouchUpInside:(id)sender;
- (IBAction)buttonPostTouchUpInside:(id)sender;
- (IBAction)buttonVideoTouchUpInside:(id)sender;
- (IBAction)buttonLikeTouchUpInside:(id)sender;
- (IBAction)buttonCommentTouchUpInside:(id)sender;

- (IBAction)buttonDeleteTouchUpInside:(id)sender;
- (IBAction)buttonConnectTouchUpInside:(id)sender;
- (IBAction)buttonShareTouchUpInside:(id)sender;
- (IBAction)buttonMoreTouchUpInside:(id)sender;
//- (IBAction)buttonLikesTouchUpInside:(id)sender;

+ (CGSize)sizeWithPost:(WLIPost*)post;


@end
