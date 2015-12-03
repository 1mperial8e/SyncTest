//
//  WLIPostCell.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostCell.h"
#import "WLIConnect.h"
#import "WLIAppDelegate.h"
#import "WLIWebViewController.h"

#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>

static WLIPostCell *sharedCell = nil;

static CGFloat const StaticCellHeight = 154;

@interface WLIPostCell () <UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeAgo;

@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UILabel *labelComments;
@property (strong, nonatomic) IBOutlet UILabel *labelLikes;

@property (weak, nonatomic) IBOutlet UIButton *buttonVideo;

@property (weak, nonatomic) IBOutlet UIView *categoryView;

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
    
    self.showFollowButton = YES;
    self.imageViewHeightConstraint.constant = 0;

    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height / 2;
    self.imageViewUser.layer.masksToBounds = YES;
    self.imageViewUser.layer.borderWidth = 2;
    self.imageViewUser.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
    
    self.buttonDelete.layer.cornerRadius = 4;
    self.buttonDelete.layer.masksToBounds = NO;
    
    self.textView.contentInset = UIEdgeInsetsZero;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    if ([self.textView respondsToSelector:@selector(layoutMargins)]) {
        self.textView.layoutMargins = UIEdgeInsetsZero;
    }
    
    UITapGestureRecognizer *textViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnTextView:)];
    [self.textView addGestureRecognizer:textViewTap];
    
    UITapGestureRecognizer *commentLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonCommentTouchUpInside:)];
    [self.labelComments addGestureRecognizer:commentLabelTap];
	
	UITapGestureRecognizer *labelLikesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getLikersForPost:)];
	[self.labelLikes addGestureRecognizer:labelLikesTap];
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
    [self.imageViewPostImage cancelImageRequestOperation];
    self.imageViewUser.image = nil;
    self.imageViewPostImage.image = nil;
    self.imageViewHeightConstraint.constant = 0;
    self.originalImage = nil;
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
    sharedCell.textView.text = post.postText.length ? post.postText : @"A";
    CGSize textSize = [sharedCell.textView sizeThatFits:CGSizeMake(width - 32, MAXFLOAT)]; // 32 left & right spacing
    CGFloat imageViewHeight = post.postImagePath.length ? (width * 245) / 292 : 5;
    return CGSizeMake(width, textSize.height + StaticCellHeight + imageViewHeight);
}

#pragma mark - Update

- (void)updateInfo
{
    if (self.post) {
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.post.user.userAvatarPath] placeholderImage:DefaultAvatar];
        self.buttonVideo.hidden = !self.post.postVideoPath.length;
        self.labelUserName.text = self.post.user.userUsername;
        self.labelTimeAgo.text = self.post.postTimeAgo;
        NSMutableAttributedString *attrString = [[WLIUtils formattedString:self.post.postText WithHashtagsAndUsers:self.post.taggedUsers] mutableCopy];
        [attrString addAttributes:@{NSFontAttributeName : self.textView.font} range:NSMakeRange(0, attrString.string.length)];
        self.textView.attributedText = attrString;

        if (self.post.postImagePath.length) {
            self.imageViewHeightConstraint.constant = (([UIScreen mainScreen].bounds.size.width - 8) * 245) / 292;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.post.postImagePath]];
            __weak typeof(self) weakSelf = self;
            [self.imageViewPostImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.originalImage = image;
                    weakSelf.imageViewPostImage.image = [weakSelf croppedImageForPreview:image];
                });
            } failure:nil];
        }
        
        self.buttonFollow.selected = self.post.user.followingUser;
        
        [self updateLikesInfo];
        [self updateCommentsInfo];
        
        if (self.post.user.userID == [WLIConnect sharedConnect].currentUser.userID) {
            self.buttonFollow.hidden = YES;
            if (self.showDeleteButton) {
                self.buttonDelete.hidden = NO;
            }
        } else {
            self.buttonFollow.hidden = !self.showFollowButton;
            self.buttonDelete.hidden = YES;
        }
        [self insertCategoryButtons];
    }
}

- (void)updateLikesInfo
{
    self.buttonLike.selected = self.post.likedThisPost;
    if (self.post.likedThisPost) {
        self.labelLikes.textColor = [UIColor redColor];
    } else {
        self.labelLikes.textColor = [UIColor colorWithWhite:76 / 255.0 alpha:1];
    }
    self.labelLikes.userInteractionEnabled = self.post.postLikesCount;
    self.labelLikes.text = [NSString stringWithFormat:@"%zd %@", self.post.postLikesCount, (self.post.postLikesCount == 1) ? @"like" : @"likes"];
}

- (void)updateCommentsInfo
{
    self.buttonComment.selected = self.post.commentedThisPost;
    if (self.post.commentedThisPost) {
        self.labelComments.textColor = [UIColor redColor];
    } else {
        self.labelComments.textColor = [UIColor colorWithWhite:76 / 255.0 alpha:1];
    }
    self.labelComments.text = [NSString stringWithFormat:@"%zd %@", self.post.postCommentsCount, (self.post.postCommentsCount == 1) ? @"comment" : @"comments"];
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
    if ([self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
        [self.delegate showUser:self.post.user userID:self.post.user.userID sender:self];
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
		self.buttonLike.userInteractionEnabled = NO;
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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([URL.absoluteString hasPrefix:@"mailto:"]) {
        [WLIUtils showEmailControllerWithToRecepient:@[[URL.absoluteString substringFromIndex:7]] delegate:self];
    } else {
        [WLIUtils showWebViewControllerWithUrl:URL];
    }
    return NO;
}

#pragma mark - Gesture

- (void)tappedOnTextView:(UITapGestureRecognizer *)gesture
{
    UITextView *textView = (UITextView *)gesture.view;
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [gesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:textView.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        NSRange range;
        NSDictionary *attributes = [textView.textStorage attributesAtIndex:characterIndex effectiveRange:&range];
        if ([attributes valueForKey:CustomLinkAttributeName]) {
            NSString *hashtag = [textView.attributedText.string substringWithRange:range];
            if ([hashtag hasPrefix:@"#"]) {
                if ([self.delegate respondsToSelector:@selector(showTimelineForSearchString:)]) {
                    [self.delegate showTimelineForSearchString:hashtag];
                }
            } else if ([hashtag hasPrefix:@"@"]) {
                NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"username LIKE %@", [hashtag substringFromIndex:1]];
                NSDictionary *userInfo = [self.post.taggedUsers filteredArrayUsingPredicate:namePredicate].firstObject;
                if (self.delegate && [self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
                    [self.delegate showUser:nil userID:[userInfo[@"id"] integerValue] sender:self];
                }
            }
        }
    }
}

- (void)getLikersForPost:(UILabel *)sender
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(showLikersListForPost:)]) {
		[self.delegate showLikersListForPost:self.post];
	}
}

#pragma mark - Utils

- (UIImage *)croppedImageForPreview:(UIImage *)srcImage
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat viewWidth = screenSize.width - 8;
    CGFloat viewHeight = (viewWidth * 245) / 292;
    CGFloat coef = 1;
    CGRect drawRect = CGRectZero;
    if (srcImage.size.height >= srcImage.size.width) {
        coef = srcImage.size.width / viewWidth;
        drawRect.origin.x = 0;
        drawRect.origin.y = -(srcImage.size.height - ((srcImage.size.width * 245) / 292)) / 2;
    } else {
        coef = srcImage.size.height / viewHeight;
        drawRect.origin.y = 0;
        drawRect.origin.x = -(srcImage.size.width - ((srcImage.size.height * 292) / 245)) / 2;
    }
    drawRect.size = srcImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(viewWidth * coef, viewHeight * coef));
    [srcImage drawInRect:drawRect];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    [[WLIUtils rootController] dismissViewControllerAnimated:YES completion:^{
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
