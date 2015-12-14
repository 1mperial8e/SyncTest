//
//  WLIUser.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIUser.h"

@implementation WLIUser

- (instancetype)initWithDictionary:(NSDictionary*)userWithInfo
{
    userWithInfo = userWithInfo.nonnullDictionary;
    self = [self init];
    if (self) {
        self.userID = [self integerFromDictionary:userWithInfo forKey:@"userID"];
        self.userType = [self integerFromDictionary:userWithInfo forKey:@"userTypeID"];
        self.userPassword = [self stringFromDictionary:userWithInfo forKey:@"password"];
        self.userEmail = [self stringFromDictionary:userWithInfo forKey:@"email"];
        self.userFullName = [self stringFromDictionary:userWithInfo forKey:@"userFullname"];
        self.userUsername = [self stringFromDictionary:userWithInfo forKey:@"username"];
        self.userInfo = [self stringFromDictionary:userWithInfo forKey:@"userInfo"];
        self.userAvatarPath = [self stringFromDictionary:userWithInfo forKey:@"userAvatar"];
        self.userAvatarThumbPath = [self stringFromDictionary:userWithInfo forKey:@"userAvatarThumb"];
        self.followingUser = [self boolFromDictionary:userWithInfo forKey:@"followingUser"];
        self.followersCount = [self integerFromDictionary:userWithInfo forKey:@"followersCount"];
        self.followingCount = [self integerFromDictionary:userWithInfo forKey:@"followingCount"];
        
        self.likesCount = [self integerFromDictionary:userWithInfo forKey:@"likesCount"];
        self.myPostsCount = [self integerFromDictionary:userWithInfo forKey:@"myPostsCount"];
    
        if (self.userFullName.length) {
            self.title = self.userFullName;
        } else if (self.userUsername.length) {
            self.title = self.userUsername;
        } else {
            self.title = @"Please add Full Name";
        }
    }
    
    return self;
}

#pragma mark - NSCoding methods

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.userID forKey:@"userID"];
    [encoder encodeInt:self.userType forKey:@"userType"];
    [encoder encodeObject:self.userPassword forKey:@"userPassword"];
    [encoder encodeObject:self.userEmail forKey:@"userEmail"];
    [encoder encodeObject:self.userFullName forKey:@"userFullName"];
    [encoder encodeObject:self.userInfo forKey:@"userInfo"];
    [encoder encodeObject:self.userAvatarPath forKey:@"userAvatarPath"];
    [encoder encodeObject:self.userUsername forKey:@"userUsername"];
    [encoder encodeInteger:self.likesCount forKey:@"likesCount"];
    [encoder encodeInteger:self.myPostsCount forKey:@"myPostsCount"];
    [encoder encodeInteger:self.followersCount forKey:@"followersCount"];
    [encoder encodeInteger:self.followingCount forKey:@"followingCount"];
    [encoder encodeInteger:self.rank forKey:@"rank"];
    [encoder encodeInteger:self.points forKey:@"points"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.userID = [decoder decodeIntForKey:@"userID"];
        self.userType = [decoder decodeIntForKey:@"userType"];
        self.userPassword = [decoder decodeObjectForKey:@"userPassword"];
        self.userEmail = [decoder decodeObjectForKey:@"email"];
        self.userFullName = [decoder decodeObjectForKey:@"userFullName"];
        self.userUsername = [decoder decodeObjectForKey:@"userUsername"];
        self.userInfo = [decoder decodeObjectForKey:@"userInfo"];
        self.userAvatarPath = [decoder decodeObjectForKey:@"userAvatarPath"];
        self.followersCount = [decoder decodeIntegerForKey:@"followersCount"];
        self.followingCount = [decoder decodeIntegerForKey:@"followingCount"];
        self.likesCount = [decoder decodeIntegerForKey:@"likesCount"];
        self.myPostsCount = [decoder decodeIntegerForKey:@"myPostsCount"];
        self.rank = [decoder decodeIntegerForKey:@"rank"];
        self.points = [decoder decodeIntegerForKey:@"points"];
    }
    return self;
}

@end
