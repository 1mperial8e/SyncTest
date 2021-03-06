//
//  WLIConnect.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "SBJson.h"
#import "AFNetworking.h"

#import "WLIUser.h"
#import "WLIPost.h"
#import "WLILike.h"
#import "WLIFollow.h"
#import "WLIComment.h"
#import "WLIHashtag.h"

enum ServerResponse {
    OK = 200,
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    FORBIDDEN = 403,
    NOT_FOUND = 404,
    CONFLICT = 409,
    SERVICE_UNAVAILABLE = 503,
    NO_CONNECTION,
    UNKNOWN_ERROR,
    PARTIAL_CONTENT,
    USER_EXISTS,
    USER_CREATED,
    LIKE_CREATED,
    LIKE_EXISTS,
	USERNAME_EXISTS = 105	
};

typedef enum ServerResponse ServerResponse;

@interface WLIConnect : NSObject

@property (readonly, nonatomic) NSDateFormatter *dateFormatter;
@property (readonly, nonatomic) NSDateFormatter *dateOnlyFormatter;

@property (strong, nonatomic) WLIUser *currentUser;

#pragma mark - Singleton

+ (instancetype)sharedConnect;

#pragma mark - UserAPI
- (void)saveCurrentUser;

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;
- (void)logout;

- (void)registerUserWithUsername:(NSString *)username
                        password:(NSString *)password
                           email:(NSString *)email
                      userAvatar:(UIImage *)userAvatar
                        userType:(int)userType
                    userFullName:(NSString *)userFullName
					   userTitle:(NSString *)userTitle
				  userDepartment:(NSString *)userDepartment
                        userInfo:(NSString *)userInfo
                    onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

- (void)userWithUserID:(NSInteger)userID onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

- (void)updateUserWithUserID:(NSInteger)userID
                    userType:(WLIUserType)userType
                   userUsername:(NSString *)userUsername
                  userAvatar:(UIImage *)userAvatar
                userFullName:(NSString *)userFullName
				   userTitle:(NSString *)userTitle
			  userDepartment:(NSString *)userDepartment
                    userInfo:(NSString *)userInfo
                    latitude:(float)latitude
                   longitude:(float)longitude
              companyAddress:(NSString *)companyAddress
                companyPhone:(NSString *)companyPhone
                  companyWeb:(NSString *)companyWeb
                onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

- (void)changePassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword withCompletion:(void (^)(ServerResponse serverResponseCode))completion;

- (void)newUsersWithPageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion;

- (void)usersForSearchString:(NSString *)searchString
                        page:(NSInteger)page
                    pageSize:(NSInteger)pageSize
                onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion;

- (void)forgotPasswordWithEmail:(NSString *)email onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

#pragma mark - Timeline

- (AFHTTPRequestOperation *)timelineForUserID:(NSInteger)userID
                     page:(NSInteger)page
                 pageSize:(NSInteger)pageSize
             onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

- (AFHTTPRequestOperation *)timelineForUserID:(NSInteger)userID
             withCategory:(NSInteger)categoryID
                     page:(NSInteger)page
                 pageSize:(NSInteger)pageSize
             onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

- (AFHTTPRequestOperation *)timelineForUserID:(NSInteger)userID
             withCategory:(NSInteger)categoryID
                countryID:(NSString *)countryID
             searchString:(NSString *)searchString
                     page:(NSInteger)page
                 pageSize:(NSInteger)pageSize
             onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

- (void)connectTimelineForUserID:(NSInteger)userID
                            page:(NSInteger)page
                        pageSize:(NSInteger)pageSize
                    onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

- (void)mydriveTimelineForUserID:(NSInteger)userID
                            page:(NSInteger)page
                        pageSize:(NSInteger)pageSize
                    onCompletion:(void (^)(NSMutableArray *posts, id rankInfo, ServerResponse serverResponseCode))completion;

#pragma mark - Posts

- (void)sendPostWithCountries:(NSString *)countries
                     postText:(NSString *)postText
                 postKeywords:(NSArray *)postKeywords
                 postCategory:(NSNumber *)postCategory
                    postImage:(UIImage *)postImage
                 onCompletion:(void (^)(WLIPost *post, ServerResponse serverResponseCode))completion;

- (void)sendPostWithCountries:(NSString *)countries
                     postText:(NSString *)postText
                 postKeywords:(NSArray *)postKeywords
                 postCategory:(NSNumber *)postCategory
                    postImage:(UIImage *)postImage
                    postVideo:(NSData *)postVideoData
                 onCompletion:(void (^)(WLIPost *post, ServerResponse serverResponseCode))completion;

- (void)recentPostsWithPageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;
- (AFHTTPRequestOperation *)popularPostsOnPage:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;
- (void)deletePostID:(NSInteger)postID onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

#pragma mark - Comments

- (void)sendCommentOnPostID:(NSInteger)postID withCommentText:(NSString *)commentText onCompletion:(void (^)(WLIComment *comment, ServerResponse serverResponseCode))completion;
- (void)removeCommentWithCommentID:(NSInteger)commentID onCompletion:(void (^)(ServerResponse serverResponseCode))completion;
- (void)commentsForPostID:(NSInteger)postID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *comments, ServerResponse serverResponseCode))completion;

#pragma mark - Likes

- (void)setLikeOnPostID:(NSInteger)postID onCompletion:(void (^)(WLILike *like, ServerResponse serverResponseCode))completion;
- (void)removeLikeWithLikeID:(NSInteger)likeID onCompletion:(void (^)(ServerResponse serverResponseCode))completion;
- (void)likesForPostID:(NSInteger)postID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *likes, ServerResponse serverResponseCode))completion;
- (void)likersForPostID:(NSInteger)postID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *likers, ServerResponse serverResponseCode))completion;

#pragma mark - Follow

- (void)setFollowOnUserID:(NSInteger)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion;
- (void)removeFollowWithFollowID:(NSInteger)followID onCompletion:(void (^)(ServerResponse serverResponseCode))completion;
- (void)followersForUserID:(NSInteger)userID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *followers, ServerResponse serverResponseCode))completion;
- (void)followingForUserID:(NSInteger)userID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *following, ServerResponse serverResponseCode))completion;

#pragma mark - Search

- (AFHTTPRequestOperation *)search:(NSString *)searchString term:(NSString *)searchTerm pageNumber:(NSInteger)pageNumber onCompletion:(void (^)(NSMutableArray *hashtags, ServerResponse serverResponseCode))completion;

#pragma mark - Email

- (void)sendEmailToRecipient:(NSString *)toRecipient withSubject:(NSString *)subject content:(NSString *)content onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

@end
