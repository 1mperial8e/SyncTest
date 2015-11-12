//
//  WLIComment.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"

@class WLIUser;

@interface WLIComment : WLIObject

@property (assign, nonatomic) NSInteger commentID;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSDate *commentDate;
@property (strong, nonatomic) NSString *commentTimeAgo;
@property (strong, nonatomic) WLIUser *user;

@end
