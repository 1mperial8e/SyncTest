//
//  WLIAnalytics.m
//  MyDrive
//
//  Created by Roman R on 01.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIAnalytics.h"


@implementation WLIAnalytics

+ (void)trackEvent:(NSString *)eventName withParameters:(NSDictionary *)eventParametersDictionary
{
	NSParameterAssert(eventName);
	if (eventParametersDictionary) {
		[Flurry logEvent:eventName withParameters:eventParametersDictionary];
	} else {
		[Flurry logEvent:eventName];
	}
}

+ (void)trackError:(NSString *)errorId withMessage:(NSString *)message withError:(NSError *)error
{
	[Flurry logError:errorId message:message error:error];
}

+ (void)setUserID:(NSString *) userID
{
	NSParameterAssert(userID);
	[Flurry setUserID:userID];
}

+ (void)startSession
{
	if (![Flurry activeSessionExists]) {
		[Flurry startSession:@"S92RNX9Y32HKPQ8S7JV3"];
	}	
}

#pragma mark - Events

+ (void)eventRegistrationWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername) {
		[parameters setObject:user.userUsername forKey:@"UserName"];
	}
	if (user.userFullName) {
		[parameters setObject:user.userFullName forKey:@"UserFullname"];
	}
	if (user.userEmail) {
		[parameters setObject:user.userEmail forKey:@"UserEmail"];
	}
	
	[self trackEvent:@"Registration" withParameters:parameters];
}

+ (void)eventRegistrationFailedWithStatusCode:(NSInteger)statusCode withUserName:(NSString *)userName withUserFullName:(NSString *)userFullName withUserEmail:(NSString *)userEmail withErrorMessage:(NSString *)errorMessage
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:statusCode] forKey:@"StatusCode"];
	if (errorMessage) {
		[parameters setObject:errorMessage forKey:@"ErrorMessage"];
	}
	if (userName) {
		[parameters setObject:userName forKey:@"UserName"];
	}
	if (userFullName) {
		[parameters setObject:userFullName forKey:@"UserFullname"];
	}
	if (userEmail) {
		[parameters setObject:userEmail forKey:@"UserEmail"];
	}
	
	[self trackEvent:@"RegistrationFailed" withParameters:parameters];
}

+ (void)eventLoginWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername) {
		[parameters setObject:user.userUsername forKey:@"UserName"];
	}
	if (user.userFullName) {
		[parameters setObject:user.userFullName forKey:@"UserFullname"];
	}
	if (user.userEmail) {
		[parameters setObject:user.userEmail forKey:@"UserEmail"];
	}
	
	[self trackEvent:@"Login" withParameters:parameters];
}

+ (void)eventLoginFailedWithStatusCode:(NSInteger)statusCode withUserName:(NSString *)userName withErrorMessage:(NSString *)errorMessage
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:statusCode] forKey:@"StatusCode"];
	if (userName) {
		[parameters setObject:userName forKey:@"UserName"];
	}
	if (errorMessage) {
		[parameters setObject:errorMessage forKey:@"ErrorMessage"];
	}
	
	[self trackEvent:@"LoginFailed" withParameters:parameters];
}

+ (void)eventAutoLoginWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername) {
		[parameters setObject:user.userUsername forKey:@"UserName"];
	}
	if (user.userFullName) {
		[parameters setObject:user.userFullName forKey:@"UserFullname"];
	}
	if (user.userEmail) {
		[parameters setObject:user.userEmail forKey:@"UserEmail"];
	}
	
	[self trackEvent:@"AutoLogin" withParameters:parameters];
}

+ (void)eventLogoutWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername) {
		[parameters setObject:user.userUsername forKey:@"UserName"];
	}
	if (user.userFullName) {
		[parameters setObject:user.userFullName forKey:@"UserFullname"];
	}
	if (user.userEmail) {
		[parameters setObject:user.userEmail forKey:@"UserEmail"];
	}
	
	[self trackEvent:@"Logout" withParameters:parameters];
}

+ (void)eventFollowWithUserId:(NSInteger)userId forUserId:(NSInteger)forUserId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:forUserId] forKey:@"ForUserId"];
	
	[self trackEvent:@"Follow" withParameters:parameters];
}

+ (void)eventUnfollowWithUserId:(NSInteger)userId forUserId:(NSInteger)forUserId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:forUserId] forKey:@"ForUserId"];
	
	[self trackEvent:@"Unfollow" withParameters:parameters];
}

+ (void)eventLikeWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	
	[self trackEvent:@"Like" withParameters:parameters];
}

+ (void)eventDislikeWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	
	[self trackEvent:@"Dislike" withParameters:parameters];
}

+ (void)eventNewPostWithUserId:(NSInteger)userId withPost:(WLIPost *)post withPostCategory:(NSInteger)postCategory withPostCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:post.postID] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	[parameters setObject:@"text" forKey:@"PostContent"];
	if (post.postVideoPath.length != 0) {
		[parameters setObject:@"video" forKey:@"PostContent"];
	}
	if (post.postImagePath.length != 0) {
		[parameters setObject:@"image" forKey:@"PostContent"];
	}
	
	[self trackEvent:@"NewPost" withParameters:parameters];
}

+ (void)eventDeletePostWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	
	[self trackEvent:@"DeletePost" withParameters:parameters];
}

+ (void)eventNewCommentWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withCommentId:(NSInteger)commentId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:commentId] forKey:@"CommentId"];
	
	[self trackEvent:@"NewComment" withParameters:parameters];
}

+ (void)eventDeleteCommentWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withCommentId:(NSInteger)commentId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:commentId] forKey:@"CommentId"];
	
	[self trackEvent:@"DeleteComment" withParameters:parameters];
}

+ (void)eventSearchWithUserId:(NSInteger)userId withSearchQuery:(NSString *)searchQuery withSearchType:(NSString *)searchType
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	if (searchQuery) {
		[parameters setObject:searchQuery forKey:@"SearchQuery"];
	}
	if (searchType) {
		[parameters setObject:searchType forKey:@"SearchType"];
	}
	
	[self trackEvent:@"Search" withParameters:parameters];
}


#pragma mark - Errors

+ (void)errorPostDelete:(NSError *)error
{
	[self trackError:@"ErrorPostDelete" withMessage:@"Delete post failed" withError:error];
}

+ (void)errorFollow:(NSError *)error
{
	[self trackError:@"ErrorFollow" withMessage:@"Follow failed" withError:error];
}

+ (void)errorLike:(NSError *)error
{
	[self trackError:@"ErrorLike" withMessage:@"Like failed" withError:error];
}

+ (void)errorLogin:(NSError *)error
{
	[self trackError:@"ErrorLogin" withMessage:@"Login failed" withError:error];
}

+ (void)errorResetPassword:(NSError *)error
{
	[self trackError:@"ErrorResetPassword" withMessage:@"Reset password failed" withError:error];
}

+ (void)errorRegistration:(NSError *)error
{
	[self trackError:@"ErrorRegistration" withMessage:@"Registration failed" withError:error];
}

+ (void)errorCommentDelete:(NSError *)error
{
	[self trackError:@"ErrorCommentDelete" withMessage:@"Delete comment failed" withError:error];
}

+ (void)errorAddEnergy:(NSError *)error
{
	[self trackError:@"ErrorAddEnergy" withMessage:@"Add Energy failed" withError:error];
}

+ (void)errorMailSend:(NSError *)error
{
	[self trackError:@"ErrorMailSend" withMessage:@"Mail send failed" withError:error];
}

+ (void)errorPostCategory:(NSError *)error
{
	[self trackError:@"ErrorPostCategory" withMessage:@"Post category response failed" withError:error];
}

+ (void)errorChangePassword:(NSError *)error
{
	[self trackError:@"ErrorChangePassword" withMessage:@"Change password failed" withError:error];
}

+ (void)errorProfileEdit:(NSError *)error
{
	[self trackError:@"ErrorProfileEdit" withMessage:@"Edit profile failed" withError:error];
}

+ (void)errorSearchResponse:(NSError *)error
{
	[self trackError:@"ErrorSearchResponse" withMessage:@"Search response error" withError:error];
}

+ (void)errorMainUpdateUser:(NSError *)error
{
	[self trackError:@"ErrorMainUpdateUser" withMessage:@"User update failed" withError:error];
}

+ (void)errorMainGetCountryList:(NSError *)error
{
	[self trackError:@"ErrorMainGetCountryList" withMessage:@"Get country list failed" withError:error];
}

@end
