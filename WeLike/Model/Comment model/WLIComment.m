//
//  WLIComment.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIComment.h"
#import "WLIUser.h"
#import "NSDate+TimeAgo.h"

@implementation WLIComment

- (instancetype)initWithDictionary:(NSDictionary *)commentWithInfo
{
    commentWithInfo = commentWithInfo.nonnullDictionary;
    self = [self init];
    if (self) {
        self.commentID = [self integerFromDictionary:commentWithInfo forKey:@"commentID"];
        self.commentText = [self stringFromDictionary:commentWithInfo forKey:@"commentText"];
        self.commentDate = [self dateFromDictionary:commentWithInfo forKey:@"commentDate"];
        if (self.commentDate) {
            self.commentTimeAgo = [self.commentDate dateTimeAgo];
        }
        NSDictionary *rawUser = [self dictionaryFromDictionary:commentWithInfo forKey:@"user"];
        self.user = [WLIUser initWithDictionary:rawUser];
    }
    return self;
}

@end
