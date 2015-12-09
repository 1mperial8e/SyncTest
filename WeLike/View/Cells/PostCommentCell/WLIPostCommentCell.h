//
//  WLIPostCommentCell.h
//  WeLike
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIComment.h"
#import "WLITableViewCell.h"

@protocol WLIPostCommentCellDelegate <NSObject>

@optional

- (void)showUser:(WLIUser *)user userID:(NSInteger)userID sender:(id)senderCell;
- (void)showAllCommentsForPostSender:(id)senderCell;
- (void)showTimelineForMySearchString:(NSString *)searchString;

@end

@interface WLIPostCommentCell : WLITableViewCell

@property (strong, nonatomic) WLIComment *comment;
@property (weak, nonatomic) id<WLIPostCommentCellDelegate> delegate;

+ (CGSize)sizeWithComment:(WLIComment *)comment;

@end
