//
//  WLIPostCell.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostCell.h"
#import "WLIConnect.h"
#import <MediaPlayer/MediaPlayer.h>

static WLIPostCell *sharedCell = nil;

static CGFloat const StaticCellHeight = 154;

@interface WLIPostCell ()

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet UILabel *labelTimeAgo;
@property (strong, nonatomic) IBOutlet UILabel *labelPostText;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) IBOutlet UIButton *buttonVideo;

@property (strong, nonatomic) IBOutlet UIView *categoryView;
@property (strong, nonatomic) UIButton *buttonCatMarket;
@property (strong, nonatomic) UIButton *buttonCatCustomer;
@property (strong, nonatomic) UIButton *buttonCatCapabilities;
@property (strong, nonatomic) UIButton *buttonCatPeople;

@property (strong, nonatomic) MPMoviePlayerViewController *movieController;

@end

@implementation WLIPostCell

#pragma mark - Object lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height / 2;
    self.imageViewUser.layer.masksToBounds = YES;
    self.imageViewUser.layer.borderWidth = 2;
    self.imageViewUser.layer.borderColor = [UIColor redColor].CGColor;
    
    self.buttonDelete.layer.cornerRadius = 4;
    self.buttonDelete.layer.masksToBounds = NO;
    
//    self.textView
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
    [self.imageViewPostImage cancelImageRequestOperation];
    self.imageViewUser.image = nil;
    self.imageViewPostImage.image = nil;
    
    self.showDeleteButton = NO;
    [self removeCategoryButtons];
}

#pragma mark - Accessors

- (void)setPost:(WLIPost *)post
{
    _post = post;
    if (post) {
        [self updateInfo];
    }
}

#pragma mark - Static

+ (CGSize)sizeWithPost:(WLIPost *)post withWidth:(CGFloat)width
{
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(WLIPostCell.class) owner:nil options:nil] lastObject];
    }
    sharedCell.labelPostText.text = post.postText.length ? post.postText : @"A";
    CGSize textSize = [sharedCell.labelPostText sizeThatFits:CGSizeMake(width - 32, MAXFLOAT)]; // 32 left & right spacing
    return CGSizeMake(width, textSize.height + StaticCellHeight + (width * 245) / 292);;
}

#pragma mark - Update

- (void)updateInfo
{
    if (self.post) {
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.post.user.userAvatarPath] placeholderImage:DefaultAvatar];
        self.buttonVideo.hidden = !self.post.postVideoPath.length;
        self.labelUserName.text = self.post.user.userFullName;
        self.labelTimeAgo.text = self.post.postTimeAgo;
        self.labelPostText.text = self.post.postText;

        if (self.post.postImagePath.length) {
            [self.imageViewPostImage setImageWithURL:[NSURL URLWithString:self.post.postImagePath]];
        } else {
            self.imageViewPostImage.image = [UIImage imageNamed:@"postPlaceholder"];
        }
        
        self.buttonLike.selected = self.post.likedThisPost;
        self.buttonFollow.selected = self.post.user.followingUser;
        
        self.labelLikes.hidden = !self.post.postLikesCount;
        self.labelLikes.text = [NSString stringWithFormat:@"%zd", self.post.postLikesCount];
        self.labelComments.hidden = !self.post.postCommentsCount;
        self.labelComments.text = [NSString stringWithFormat:@"%zd", self.post.postCommentsCount];

        if (self.post.user.userID == [WLIConnect sharedConnect].currentUser.userID) {
            self.buttonFollow.hidden = YES;
            if (self.showDeleteButton) {
                self.buttonDelete.hidden = NO;
            }
        } else {
            self.buttonFollow.hidden = NO;
            self.buttonDelete.hidden = YES;
        }
        
        [self insertCategoryButtons];
    }
}

#pragma mark - Category buttons

- (void)insertCategoryButtons
{
    UIFont *buttonsFont = [UIFont systemFontOfSize:12.0];
    CGFloat leftSpacing = 10;
    CGFloat lastButtonMaxX = leftSpacing;
    CGRect firstButtonFrame = CGRectMake(0, (CGRectGetHeight(self.categoryView.frame) - 30) / 2, 20, 30);
    
    if (self.post.categoryMarket) {
        self.buttonCatMarket = [self buttonWithTitle:@"Market"];
        firstButtonFrame.size.width = [[self.buttonCatMarket titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : buttonsFont}].width;
        firstButtonFrame.origin.x = lastButtonMaxX;
        self.buttonCatMarket.frame = firstButtonFrame;
        [self.buttonCatMarket addTarget:self action:@selector(buttonCatMarketTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.categoryView addSubview:self.buttonCatMarket];
        lastButtonMaxX = CGRectGetMaxX(firstButtonFrame) + leftSpacing;
    }
    if (self.post.categoryCustomer) {
        self.buttonCatCustomer = [self buttonWithTitle:@"Customer"];
        firstButtonFrame.size.width = [[self.buttonCatCustomer titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : buttonsFont}].width;
        firstButtonFrame.origin.x = lastButtonMaxX;
        self.buttonCatCustomer.frame = firstButtonFrame;
        [self.buttonCatCustomer addTarget:self action:@selector(buttonCatCustomerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.categoryView addSubview:self.buttonCatCustomer];
        lastButtonMaxX = CGRectGetMaxX(firstButtonFrame) + leftSpacing;
    }
    if (self.post.categoryCapabilities) {
        self.buttonCatCapabilities = [self buttonWithTitle:@"Capabilities"];
        firstButtonFrame.size.width = [[self.buttonCatCapabilities titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : buttonsFont}].width;
        firstButtonFrame.origin.x = lastButtonMaxX;
        self.buttonCatCapabilities.frame = firstButtonFrame;
        [self.buttonCatCapabilities addTarget:self action:@selector(buttonCatCapabilitiesTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.categoryView addSubview:self.buttonCatCapabilities];
        lastButtonMaxX = CGRectGetMaxX(firstButtonFrame) + leftSpacing;
    }
    if (self.post.categoryPeople) {
        self.buttonCatPeople = [self buttonWithTitle:@"People"];
        firstButtonFrame.size.width = [[self.buttonCatPeople titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : buttonsFont}].width;
        firstButtonFrame.origin.x = lastButtonMaxX;
        self.buttonCatPeople.frame = firstButtonFrame;
        [self.buttonCatPeople addTarget:self action:@selector(buttonCatPeopleTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.categoryView addSubview:self.buttonCatPeople];
        lastButtonMaxX = CGRectGetMaxX(firstButtonFrame) + leftSpacing;
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12.f];
    return button;
}

- (void)removeCategoryButtons
{
    [self.buttonCatMarket removeFromSuperview];
    [self.buttonCatCustomer removeFromSuperview];
    [self.buttonCatCapabilities removeFromSuperview];
    [self.buttonCatPeople removeFromSuperview];
}

#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.post.user sender:self];
    }
}

- (IBAction)buttonPostTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showImageForPost:sender:)] && self.post.postImagePath.length) {
        [self.delegate showImageForPost:self.post sender:self];
    }
}

- (IBAction)buttonVideoTouchUpInside:(id)sender
{
    NSURL *movieURL = [NSURL URLWithString:self.post.postVideoPath];
    self.movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self.delegate presentMoviePlayerViewControllerAnimated:self.movieController];
    [self.movieController.moviePlayer play];
}

- (IBAction)buttonLikeTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(toggleLikeForPost:sender:)]) {
        [self.delegate toggleLikeForPost:self.post sender:self];
    }
}

- (IBAction)buttonCommentTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showCommentsForPost:sender:)]) {
        [self.delegate showCommentsForPost:self.post sender:self];
    }
}

- (void)buttonCatMarketTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showCatMarketForPost:sender:)]) {
        [self.delegate showCatMarketForPost:self.post sender:self];
    }
}

- (void)buttonCatCustomerTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showCatCustomersForPost:sender:)]) {
        [self.delegate showCatCustomersForPost:self.post sender:self];
    }
}

- (void)buttonCatCapabilitiesTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showCatCapabilitiesForPost:sender:)]) {
        [self.delegate showCatCapabilitiesForPost:self.post sender:self];
    }
}

- (void)buttonCatPeopleTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showCatPeopleForPost:sender:)]) {
        [self.delegate showCatPeopleForPost:self.post sender:self];
    }
}

- (IBAction)buttonDeleteTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deletePost:sender:)]) {
        [self.delegate deletePost:self.post sender:self];
    }
}

- (IBAction)followButtonAction:(id)sender
{
    if (self.post.user.followingUser) {
        if ([self.delegate respondsToSelector:@selector(unfollowUser:sender:)]) {
            [self.delegate unfollowUser:self.post.user sender:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(followUser:sender:)]) {
            [self.delegate followUser:self.post.user sender:self];
        }
    }
}

@end
