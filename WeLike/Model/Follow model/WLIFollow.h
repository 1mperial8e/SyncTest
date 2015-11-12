//
//  WLIFollow.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.+
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import "WLIUser.h"

@interface WLIFollow : WLIObject

@property (assign, nonatomic) NSInteger followID;
@property (strong, nonatomic) NSDate *followDate;
@property (strong, nonatomic) WLIUser *follower;
@property (strong, nonatomic) WLIUser *following;

@end
