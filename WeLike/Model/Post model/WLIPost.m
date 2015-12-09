//
//  WLIPost.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPost.h"
#import "NSDate+TimeAgo.h"
#import "WLIComment.h"

@implementation WLIPost

- (instancetype)initWithDictionary:(NSDictionary *)postWithInfo
{
    postWithInfo = postWithInfo.nonnullDictionary;
    self = [self init];
    if (self) {
        self.postID = [self integerFromDictionary:postWithInfo forKey:@"postID"];
        self.postTitle = [self stringFromDictionary:postWithInfo forKey:@"postTitle"];
        self.postText = [self stringFromDictionary:postWithInfo forKey:@"postText"];
        self.postImagePath = [self stringFromDictionary:postWithInfo forKey:@"postImage"];
		self.postImageThumbPath = [self stringFromDictionary:postWithInfo forKey:@"postThumb"];
        self.postVideoPath = [self stringFromDictionary:postWithInfo forKey:@"postVideo"];
        self.postDate = [self dateFromDictionary:postWithInfo forKey:@"postDate"];
        self.postTimeAgo = [self stringFromDictionary:postWithInfo forKey:@"timeAgo"];
        NSDictionary *rawUser = [self dictionaryFromDictionary:postWithInfo forKey:@"user"];
        self.user = [WLIUser initWithDictionary:rawUser];
        self.postLikesCount = [self integerFromDictionary:postWithInfo forKey:@"totalLikes"];
        self.postCommentsCount = [self integerFromDictionary:postWithInfo forKey:@"totalComments"];
        self.likedThisPost = [self boolFromDictionary:postWithInfo forKey:@"isLiked"];
        self.isConnected = [self boolFromDictionary:postWithInfo forKey:@"isConnected"];
        self.user.followingUser = self.isConnected;
        self.commentedThisPost = [self boolFromDictionary:postWithInfo forKey:@"isCommented"];
		self.postComments = [WLIComment arrayWithDictionariesArray:[postWithInfo objectForKey:@"comments"]];
		
        self.categoryMarket = [self integerFromDictionary:postWithInfo forKey:@"categoryID"] & 1;
        self.categoryCapabilities = [self integerFromDictionary:postWithInfo forKey:@"categoryID"] & 2;
        self.categoryCustomer = [self integerFromDictionary:postWithInfo forKey:@"categoryID"] & 4;
        self.categoryPeople = [self integerFromDictionary:postWithInfo forKey:@"categoryID"] & 8;
        
        self.taggedUsers = [self arrayFromDictionary:postWithInfo forKey:@"tagged_users"];
    }
        
    return self;
}

@end
