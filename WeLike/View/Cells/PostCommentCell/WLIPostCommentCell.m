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

@interface WLIPostCommentCell ()

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

- (void)prepareForReuse
{
    [super prepareForReuse];
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
		NSString *theText = [NSString stringWithFormat:@"%@ %@",self.comment.user.userUsername,self.comment.commentText];
        NSMutableAttributedString *attrString = [WLIUtils formattedString:theText WithHashtagsAndUsers:self.comment.taggedUsers].mutableCopy;
        [attrString addAttributes:@{NSFontAttributeName : self.textView.font} range:NSMakeRange(0, attrString.string.length)];
        self.textView.attributedText = attrString;
    }
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
                NSDictionary *userInfo = [self.comment.taggedUsers filteredArrayUsingPredicate:namePredicate].firstObject;
                if (self.delegate && [self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
                    [self.delegate showUser:nil userID:[userInfo[@"id"] integerValue] sender:self];
                }
            }
        }
    }
}


#pragma mark - Actions

- (IBAction)buttonUserTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showUser:userID:sender:)]) {
        [self.delegate showUser:self.comment.user userID:self.comment.user.userID sender:self];
    }
}

#pragma mark - Static

+ (CGSize)sizeWithComment:(WLIComment *)comment
{
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCommentCell" owner:nil options:nil] lastObject];
    }
	NSString *theText = [NSString stringWithFormat:@"%@ %@",comment.user.userUsername,comment.commentText];
    sharedCell.textView.text = comment.commentText.length ? theText : @"A";
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize textSize = [sharedCell.textView sizeThatFits:CGSizeMake(width - 50, MAXFLOAT)]; // 54 left & right spacing

    return CGSizeMake(width, textSize.height);
}

@end
