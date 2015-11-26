//
//  WLIPost.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import "WLIUser.h"

@interface WLIPost : WLIObject

@property (assign, nonatomic) NSInteger postID;
@property (strong, nonatomic) NSString *postTitle;
@property (strong, nonatomic) NSString *postText;
@property (strong, nonatomic) NSString *postImagePath;
@property (strong, nonatomic) NSString *postVideoPath;
@property (strong, nonatomic) NSDate *postDate;
@property (strong, nonatomic) NSString *postTimeAgo;
@property (strong, nonatomic) NSMutableArray *postKeywords;
@property (strong, nonatomic) WLIUser *user;
@property (assign, nonatomic) NSInteger postLikesCount;
@property (assign, nonatomic) NSInteger postCommentsCount;
@property (strong, nonatomic) NSArray *taggedUsers;

@property (assign, nonatomic) BOOL likedThisPost;
@property (assign, nonatomic) BOOL isConnected;
@property (assign, nonatomic) BOOL commentedThisPost;

@property (assign, nonatomic) BOOL categoryMarket;
@property (assign, nonatomic) BOOL categoryCustomer;
@property (assign, nonatomic) BOOL categoryCapabilities;
@property (assign, nonatomic) BOOL categoryPeople;

@end
