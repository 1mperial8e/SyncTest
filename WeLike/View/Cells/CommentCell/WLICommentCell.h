//
//  WLICommentCell.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIComment.h"
#import "WLITableViewCell.h"

@interface WLICommentCell : WLITableViewCell

@property (strong, nonatomic) WLIComment *comment;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

+ (CGSize)sizeWithComment:(WLIComment *)comment;

@end
