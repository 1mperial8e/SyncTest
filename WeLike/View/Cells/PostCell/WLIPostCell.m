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

#import "WLIPostCommentCell.h"

static WLIPostCell *sharedCell = nil;

static CGFloat const StaticCellHeight = 140;

@interface WLIPostCell () <UITextViewDelegate, MFMailComposeViewControllerDelegate, WLIPostCommentCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeAgo;
@property (weak, nonatomic) IBOutlet UIButton *buttonUser;

@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seeMoreButtonHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *buttonComment;
@property (weak, nonatomic) IBOutlet UILabel *labelComments;
@property (weak, nonatomic) IBOutlet UILabel *labelLikes;

@property (weak, nonatomic) IBOutlet UIButton *buttonVideo;

@property (weak, nonatomic) IBOutlet UIView *categoryView;

@property (strong, nonatomic) UIButton *buttonCatMarket;
@property (strong, nonatomic) UIButton *buttonCatCustomer;
@property (strong, nonatomic) UIButton *buttonCatCapabilities;
@property (strong, nonatomic) UIButton *buttonCatPeople;

@property (strong, nonatomic) MPMoviePlayerViewController *movieController;

@property (strong, nonatomic) NSMutableArray *commentViews;

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
	
	UITapGestureRecognizer *labelUserNameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonUserTouchUpInside:)];
	[self.labelUserName addGestureRecognizer:labelUserNameTap];
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
	[self removeCommentsFromCell];
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
    sharedCell.textView.text = post.postText.length ? [post.user.userUsername stringByAppendingFormat:@" %@", post.postText] : @"A";
    CGSize textSize = [sharedCell.textView sizeThatFits:CGSizeMake(width - 32, MAXFLOAT)]; // 32 left & right spacing
    CGFloat imageViewHeight = post.postImagePath.length ? (width * 245) / 292 : 5;
	CGFloat commentsHeigh = 8;
	for (WLIComment *postComment in post.postComments) {
		CGFloat currentCommentHeight = [WLIPostCommentCell sizeWithComment:postComment].height;
		commentsHeigh += currentCommentHeight;
	}
    CGFloat seeMoreLabelHeight = post.postCommentsCount > 3 ? 23 : 0;
    return CGSizeMake(width, textSize.height + StaticCellHeight + imageViewHeight + commentsHeigh + seeMoreLabelHeight);
}

#pragma mark - Update

- (void)updateInfo
{
    if (self.post) {
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.post.user.userAvatarThumbPath] placeholderImage:DefaultAvatar];
        self.buttonVideo.hidden = !self.post.postVideoPath.length;
        self.labelUserName.text = self.post.user.userFullName;
        self.labelTimeAgo.text = self.post.postTimeAgo;
        NSMutableAttributedString *attrString = [[WLIUtils formattedString:[self.post.user.userUsername stringByAppendingFormat:@" %@", self.post.postText] WithHashtagsAndUsers:self.post.taggedUsers] mutableCopy];
        [attrString addAttributes:@{NSFontAttributeName : self.textView.font} range:NSMakeRange(0, attrString.string.length)];
        NSRange usernameRange = NSMakeRange(0, self.post.user.userUsername.length);
        [attrString addAttributes:@{NSForegroundColorAttributeName : [UIColor redColor], CustomLinkAttributeName : @1} range:usernameRange];
        self.textView.attributedText = attrString;
        
        self.seeMoreButtonHeightConstraint.constant = self.post.postCommentsCount > 3 ? 23 : 0;
        
        if (self.post.postImagePath.length) {
            self.imageViewHeightConstraint.constant = (([UIScreen mainScreen].bounds.size.width - 8) * 245) / 292;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.post.postImageThumbPath]];			
            __weak typeof(self) weakSelf = self;
			[self.imageActivityIndicator startAnimating];
            [self.imageViewPostImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull thumb) {
                [weakSelf.imageActivityIndicator stopAnimating];
                weakSelf.imageViewPostImage.image = thumb;
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:weakSelf.post.postImagePath]];
                [weakSelf.imageViewPostImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                    weakSelf.imageViewPostImage.image = image;
                    weakSelf.originalImage = image;
                } failure:nil];
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:weakSelf.post.postImagePath]];
                [weakSelf.imageViewPostImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                    [weakSelf.imageActivityIndicator stopAnimating];
                    weakSelf.imageViewPostImage.image = image;
                    weakSelf.originalImage = image;
                } failure:nil];
            }];
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
		[self insertCommentsToCell];
	}
}

- (void)insertCommentsToCell
{
	__block CGFloat commentOffset = 8;
	self.commentViews = [[NSMutableArray alloc] init];
    [self.post.postComments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(WLIComment   * _Nonnull postComment, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"WLIPostCommentCell" owner:self options:nil];
        WLIPostCommentCell *cell = [viewArray firstObject];
        cell.comment = postComment;
        CGFloat commentHeight = [WLIPostCommentCell sizeWithComment:postComment].height;
        cell.frame = CGRectMake(0, commentOffset, [UIScreen mainScreen].bounds.size.width - 16, commentHeight);
        commentOffset += commentHeight;
        [self.commentsContainer addSubview:cell];
        [self.commentViews addObject:cell];
        cell.delegate = self;
    }];
    self.commentsContainerHeightConstraint.constant = commentOffset;
    [self layoutIfNeeded];
}

- (void)removeCommentsFromCell
{
	for (UIView *cellView in self.commentViews) {
		[cellView removeFromSuperview];
	}
    [self.commentViews removeAllObjects];
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
    if (self.post.postCommentsCount == 0) {
        self.post.commentedThisPost = NO;
    }
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
        [WLIUtils showCustomEmailControllerWithToRecepient:[URL.absoluteString substringFromIndex:7]];
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
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
                    [self.delegate showUser:nil userID:self.post.user.userID sender:self];
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(showAllCommentsForPostSender:)]) {
                [self buttonCommentTouchUpInside:self];
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

- (void)blockUserInteraction
{
	self.labelUserName.userInteractionEnabled = NO;
	self.buttonUser.userInteractionEnabled=NO;
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

#pragma mark - WLIPostCommentCellDelegate

- (void)showUser:(WLIUser *)user userID:(NSInteger)userID sender:(id)senderCell
{
	if ([self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
		[self.delegate showUser:user userID:userID sender:self];
	}
}

- (void)showAllCommentsForPostSender:(id)sender
{
	[self buttonCommentTouchUpInside:sender];
}

- (void)showTimelineForMySearchString:(NSString *)searchString
{
	if ([self.delegate respondsToSelector:@selector(showTimelineForSearchString:)]) {
		[self.delegate showTimelineForSearchString:searchString];
	}
}

@end
