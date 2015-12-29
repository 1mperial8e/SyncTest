//
//  WLIUser.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"

typedef NS_ENUM(NSInteger, WLIUserType) {
    WLIUserTypeUnknown = 0,
    WLIUserTypePerson = 1,
    WLIUserTypeCompany = 2
};

@interface WLIUser : WLIObject

@property (assign, nonatomic) NSInteger userID;
@property (assign, nonatomic) WLIUserType userType;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *userFullName;
@property (strong, nonatomic) NSString *userDepartment;
@property (strong, nonatomic) NSString *userTitle;
@property (strong, nonatomic) NSString *userInfo;
@property (strong, nonatomic) NSString *userAvatarPath;
@property (strong, nonatomic) NSString *userAvatarThumbPath;
@property (strong, nonatomic) NSString *userUsername;
@property (assign, nonatomic) BOOL followingUser;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;

@property (assign, nonatomic) NSInteger rank;
@property (assign, nonatomic) NSInteger points;

@property (assign, nonatomic) NSInteger followersCount;
@property (assign, nonatomic) NSInteger followingCount;

@property (assign, nonatomic) NSInteger likesCount;
@property (assign, nonatomic) NSInteger myPostsCount;

@end
