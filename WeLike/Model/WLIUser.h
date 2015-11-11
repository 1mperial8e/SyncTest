//
//  WLIUser.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
//#import <CoreLocation/CoreLocation.h>
//#import <MapKit/MapKit.h>

typedef enum {
    WLIUserTypeUnknown = 0,
    WLIUserTypePerson = 1,
    WLIUserTypeCompany = 2
} WLIUserType;

@interface WLIUser : WLIObject

@property (assign, nonatomic) NSInteger userID;
@property (nonatomic) WLIUserType userType;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userFullName;
@property (nonatomic, strong) NSString *userInfo;
@property (nonatomic, strong) NSString *userAvatarPath;
@property (nonatomic, strong) NSString *userUsername;
@property (nonatomic, assign) BOOL followingUser;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic) int followersCount;
@property (nonatomic) int followingCount;

@property (nonatomic) int likesCount;
@property (nonatomic) int myPostsCount;

- (id)initWithDictionary:(NSDictionary*)userWithInfo;

@end
