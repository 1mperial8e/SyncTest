//
//  WLIComment.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIComment.h"
#import "NSDate+TimeAgo.h"

@implementation WLIComment

//Initializes WLIComment object from NSDictionary that was created by JSON parsing.
- (id)initWithDictionary:(NSDictionary*)commentWithInfo
{
    commentWithInfo = commentWithInfo.nonnullDictionary;
    self = [self init];
    if (self) {
        
        _commentID = [self integerFromDictionary:commentWithInfo forKey:@"commentID"];
        _commentText = [self stringFromDictionary:commentWithInfo forKey:@"commentText"];
        _commentDate = [self dateFromDictionary:commentWithInfo forKey:@"commentDate"];
        if (_commentDate) {
            _commentTimeAgo = [_commentDate dateTimeAgo];
        }
        
        NSDictionary *rawUser = [self dictionaryFromDictionary:commentWithInfo forKey:@"user"];
        _user = [[WLIUser alloc] initWithDictionary:rawUser];
    }
    
    return self;
}

@end
