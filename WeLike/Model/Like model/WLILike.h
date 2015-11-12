//
//  WLILike.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import "WLIUser.h"

@interface WLILike : WLIObject

@property (assign, nonatomic) NSInteger likeID;
@property (strong, nonatomic) WLIUser *user;

@end
