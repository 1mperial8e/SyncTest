//
//  WLIFollow.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIFollow.h"

@implementation WLIFollow

- (instancetype)initWithDictionary:(NSDictionary *)followWithInfo
{
    followWithInfo = followWithInfo.nonnullDictionary;
    self = [self init];
    if (self) {
        self.followID = [self integerFromDictionary:followWithInfo forKey:@"followID"];
        self.followDate = [self dateFromDictionary:followWithInfo forKey:@"followDate"];
        NSDictionary *rawFollower = [self dictionaryFromDictionary:followWithInfo forKey:@"follower"];
        self.follower = [WLIUser initWithDictionary:rawFollower];
        NSDictionary *rawFollowing = [self dictionaryFromDictionary:followWithInfo forKey:@"following"];
        self.following = [WLIUser initWithDictionary:rawFollowing];
    }
    return self;
}


@end
