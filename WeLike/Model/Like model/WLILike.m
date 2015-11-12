//
//  WLILike.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLILike.h"

@implementation WLILike

- (instancetype)initWithDictionary:(NSDictionary *)likeWithInfo
{
    likeWithInfo = likeWithInfo.nonnullDictionary;
    self = [self init];
    if (self) {
        self.likeID = [self integerFromDictionary:likeWithInfo forKey:@"likeID"];
        NSDictionary *rawUser = [self dictionaryFromDictionary:likeWithInfo forKey:@"user"];
        self.user = [WLIUser initWithDictionary:rawUser];
    }
    return self;
}

@end
