//
//  WLIAnalytics.h
//  MyDrive
//
//  Created by Roman R on 01.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "Flurry.h"
#import "WLIPost.h"
#import "WLIUser.h"

@interface WLIAnalytics : NSObject

+ (void)trackEvent:(NSString *)eventName withParameters:(NSDictionary *)params;
+ (void)setUserID:(NSString *) userID;
+ (void)startSession;

#pragma mark - Events

+ (void)eventRegistrationWithUser:(WLIUser *)user;
+ (void)eventRegistrationFailedWithStatusCode:(NSInteger)statusCode withUserName:(NSString *)userName withUserFullName:(NSString *)userFullName withUserEmail:(NSString *)userEmail withErrorMessage:(NSString *)errorMessage;
+ (void)eventLoginWithUser:(WLIUser *)user;
+ (void)eventLoginFailedWithStatusCode:(NSInteger)statusCode withUserName:(NSString *)userName withErrorMessage:(NSString *)errorMessage;
+ (void)eventAutoLoginWithUser:(WLIUser *)user;
+ (void)eventLogoutWithUser:(WLIUser *)user;
+ (void)eventFollowWithUserId:(NSInteger)userId forUserId:(NSInteger)forUserId;
+ (void)eventUnfollowWithUserId:(NSInteger)userId forUserId:(NSInteger)forUserId;
+ (void)eventLikeWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country;
+ (void)eventDislikeWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country;
+ (void)eventNewPostWithUserId:(NSInteger)userId withPost:(WLIPost *)post withPostCategory:(NSInteger)postCategory withPostCountry:(NSInteger)country;
+ (void)eventDeletePostWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country;
+ (void)eventNewCommentWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withCommentId:(NSInteger)commentId;
+ (void)eventDeleteCommentWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withCommentId:(NSInteger)commentId;
+ (void)eventSearchWithUserId:(NSInteger)userId withSearchQuery:(NSString *)searchQuery withSearchType:(NSString *)searchType;

#pragma mark - Errors

+ (void)errorPostDelete:(NSError *)error;
+ (void)errorFollow:(NSError *)error;
+ (void)errorLike:(NSError *)error;
+ (void)errorLogin:(NSError *)error;
+ (void)errorResetPassword:(NSError *)error;
+ (void)errorRegistration:(NSError *)error;
+ (void)errorCommentDelete:(NSError *)error;
+ (void)errorAddEnergy:(NSError *)error;
+ (void)errorMailSend:(NSError *)error;
+ (void)errorPostCategory:(NSError *)error;
+ (void)errorChangePassword:(NSError *)error;
+ (void)errorProfileEdit:(NSError *)error;
+ (void)errorSearchResponse:(NSError *)error;
+ (void)errorMainUpdateUser:(NSError *)error;
+ (void)errorMainGetCountryList:(NSError *)error;

@end
