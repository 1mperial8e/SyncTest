//
//  WLIPostCommentCell.m
//  WeLike
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIPostCommentCell.h"
#import "UIImageView+AFNetworking.h"
#import <MessageUI/MessageUI.h>

static WLIPostCommentCell *sharedCell = nil;
static  NSInteger postCommentLinesCount = 5;

@interface WLIPostCommentCell () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation WLIPostCommentCell

#pragma mark - Object lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
	
    self.textView.delegate = self;
    self.textView.contentInset = UIEdgeInsetsZero;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    if ([self.textView respondsToSelector:@selector(layoutMargins)]) {
        self.textView.layoutMargins = UIEdgeInsetsZero;
    }
	
	UITapGestureRecognizer *textViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnTextView:)];
	[self.textView addGestureRecognizer:textViewTap];
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
		NSString *text = [NSString stringWithFormat:@"%@ %@",self.comment.user.userUsername, self.comment.commentText];
		
		self.textView.text = text;
        CGFloat height = ceilf([self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, MAXFLOAT)].height);
        NSInteger lines = (int)(height / self.textView.font.lineHeight);

		if (lines > postCommentLinesCount) {
			NSInteger newLength = text.length * (postCommentLinesCount / (CGFloat)lines);
			text = [text substringToIndex:newLength - 5];
			text = [text stringByAppendingString:@" ..."];
		}
		self.textView.text = nil;
		NSMutableAttributedString *attrString = [WLIUtils formattedString:text WithHashtagsAndUsers:self.comment.taggedUsers].mutableCopy;
		[attrString addAttributes:@{NSFontAttributeName : self.textView.font} range:NSMakeRange(0, attrString.string.length)];
		[attrString addAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(0, self.comment.user.userUsername.length)];
		[attrString addAttributes:@{CustomLinkAttributeName : @YES} range:NSMakeRange(0, self.comment.user.userUsername.length)];
		self.textView.attributedText = attrString;
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

#pragma mark - Gestures

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
				if ([self.delegate respondsToSelector:@selector(showTimelineForMySearchString:)]) {
					[self.delegate showTimelineForMySearchString:hashtag];
				}
			} else if ([hashtag hasPrefix:@"@"]) {
				NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"username LIKE %@", [hashtag substringFromIndex:1]];
				NSDictionary *userInfo = [self.comment.taggedUsers filteredArrayUsingPredicate:namePredicate].firstObject;
				if (self.delegate && [self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
					[self.delegate showUser:nil userID:[userInfo[@"id"] integerValue] sender:self];
				}
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
                    [self.delegate showUser:nil userID:self.comment.user.userID sender:self];
                }
            }
		} else {
			if ([self.delegate respondsToSelector:@selector(showAllCommentsForPostSender:)]) {
				[self.delegate showAllCommentsForPostSender:self];
			}
		}
	}
}

#pragma mark - Static

+ (CGSize)sizeWithComment:(WLIComment *)comment
{
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCommentCell" owner:nil options:nil] lastObject];
    }
	CGFloat width = [UIScreen mainScreen].bounds.size.width;
	NSString *text = [NSString stringWithFormat:@"%@ %@", comment.user.userUsername, comment.commentText];
    sharedCell.textView.text = comment.commentText.length ? text : @"A";
	CGFloat height = ceilf([sharedCell.textView sizeThatFits:CGSizeMake(sharedCell.textView.frame.size.width, MAXFLOAT)].height);
	NSInteger lines = (int)(height / sharedCell.textView.font.lineHeight);
	
	if (lines > postCommentLinesCount) {
		NSInteger newLength = text.length * (postCommentLinesCount / (CGFloat)lines);
		text = [text substringToIndex:newLength - 5];
		text= [text stringByAppendingString:@" ..."];
		sharedCell.textView.text = text;
		height = ceilf([sharedCell.textView sizeThatFits:CGSizeMake(sharedCell.textView.frame.size.width, MAXFLOAT)].height);
	}
    return CGSizeMake(width, height + 8.5);
}

@end
