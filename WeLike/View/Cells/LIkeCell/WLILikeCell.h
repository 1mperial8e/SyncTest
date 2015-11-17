//
//  WLILikeCell.h
//  WeLike
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITableViewCell.h"
#import "WLILike.h"

@interface WLILikeCell : WLITableViewCell

@property (assign, nonatomic) id<WLICellDelegate> delegate;
@property (strong, nonatomic) WLILike *like;

+ (CGSize)sizeWithLike:(WLILike *)like;

@end
