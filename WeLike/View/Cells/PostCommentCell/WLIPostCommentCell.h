//
//  WLIPostCommentCell.h
//  WeLike
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIComment.h"
#import "WLITableViewCell.h"

@interface WLIPostCommentCell : WLITableViewCell

@property (strong, nonatomic) WLIComment *comment;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

+ (CGSize)sizeWithComment:(WLIComment *)comment;

@end
