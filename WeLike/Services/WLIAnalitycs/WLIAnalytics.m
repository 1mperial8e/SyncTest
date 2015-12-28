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

//1	Registration	Prod/Dev	UserId	UserName	UserFullname	UserEmail
+ (void)eventRegistrationWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername)  [parameters setObject:user.userUsername forKey:@"UserName"];
	if (user.userFullName)  [parameters setObject:user.userFullName forKey:@"UserFullname"];
	if (user.userEmail)  [parameters setObject:user.userEmail forKey:@"UserEmail"];
	
	[self trackEvent:@"Registration" withParameters:parameters];
}

//2	RegistrationFailed	Prod/Dev	StatusCode	UserName	UserFullname	UserEmail	 ErrorMessage
+ (void)eventRegistrationFailedWithStatusCode:(NSInteger)statusCode withUserName:(NSString *)userName withUserFullName:(NSString *)userFullName withUserEmail:(NSString *)userEmail withErrorMessage:(NSString *)errorMessage
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:statusCode] forKey:@"StatusCode"];
	if (errorMessage)  [parameters setObject:errorMessage forKey:@"ErrorMessage"];
	if (userName)  [parameters setObject:userName forKey:@"UserName"];
	if (userFullName)  [parameters setObject:userFullName forKey:@"UserFullname"];
	if (userEmail)  [parameters setObject:userEmail forKey:@"UserEmail"];
	
	[self trackEvent:@"RegistrationFailed" withParameters:parameters];
}

//3	Login	Prod/Dev	UserId	UserName	UserFullname	UserEmail
+ (void)eventLoginWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername)  [parameters setObject:user.userUsername forKey:@"UserName"];
	if (user.userFullName)  [parameters setObject:user.userFullName forKey:@"UserFullname"];
	if (user.userEmail)  [parameters setObject:user.userEmail forKey:@"UserEmail"];
	
	[self trackEvent:@"Login" withParameters:parameters];
}

//4	LoginFailed	Prod/Dev	StatusCode	UserName			 ErrorMessage
+ (void)eventLoginFailedWithStatusCode:(NSInteger)statusCode withUserName:(NSString *)userName withErrorMessage:(NSString *)errorMessage
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:statusCode] forKey:@"StatusCode"];
	if (userName)  [parameters setObject:userName forKey:@"UserName"];
	if (errorMessage)  [parameters setObject:errorMessage forKey:@"ErrorMessage"];
	
	[self trackEvent:@"LoginFailed" withParameters:parameters];
}


//5	AutoLogin	Prod/Dev	UserId	UserName	UserFullname	UserEmail
+ (void)eventAutoLoginWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername)  [parameters setObject:user.userUsername forKey:@"UserName"];
	if (user.userFullName)  [parameters setObject:user.userFullName forKey:@"UserFullname"];
	if (user.userEmail)  [parameters setObject:user.userEmail forKey:@"UserEmail"];
	
	[self trackEvent:@"AutoLogin" withParameters:parameters];
}

//6	Logout	Prod/Dev	UserId	UserName	UserFullname	UserEmail
+ (void)eventLogoutWithUser:(WLIUser *)user
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:user.userID] forKey:@"UserId"];
	if (user.userUsername)  [parameters setObject:user.userUsername forKey:@"UserName"];
	if (user.userFullName)  [parameters setObject:user.userFullName forKey:@"UserFullname"];
	if (user.userEmail)  [parameters setObject:user.userEmail forKey:@"UserEmail"];
	
	[self trackEvent:@"Logout" withParameters:parameters];
}

//7	Follow	Prod/Dev	UserId	ForUserId
+ (void)eventFollowWithUserId:(NSInteger)userId forUserId:(NSInteger)forUserId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:forUserId] forKey:@"ForUserId"];
	
	[self trackEvent:@"Follow" withParameters:parameters];
}

//8	Unfollow	Prod/Dev	UserId	ForUserId
+ (void)eventUnfollowWithUserId:(NSInteger)userId forUserId:(NSInteger)forUserId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:forUserId] forKey:@"ForUserId"];
	
	[self trackEvent:@"Unfollow" withParameters:parameters];
}

//9	Like	Prod/Dev	UserId	PostId	PostCategory	Country
+ (void)eventLikeWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	
	[self trackEvent:@"Like" withParameters:parameters];
}

//10	Dislike	Prod/Dev	UserId	PostId	PostCategory	Country
+ (void)eventDislikeWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	
	[self trackEvent:@"Dislike" withParameters:parameters];
}

//11	NewPost	Prod/Dev	UserId	PostId	PostCategory	Country	PostContent (Image/video/text)
+ (void)eventNewPostWithUserId:(NSInteger)userId withPost:(WLIPost *)post withPostCategory:(NSInteger)postCategory withPostCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:post.postID] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	[parameters setObject:@"text" forKey:@"PostContent"];
	if (post.postVideoPath.length != 0)  [parameters setObject:@"video" forKey:@"PostContent"];
	if (post.postImagePath.length != 0)  [parameters setObject:@"image" forKey:@"PostContent"];
	
	[self trackEvent:@"NewPost" withParameters:parameters];
}

//12	DeletePost	Prod/Dev	UserId	PostId	PostCategory	Country
+ (void)eventDeletePostWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withPostCategory:(NSInteger)postCategory withCountry:(NSInteger)country
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:postCategory] forKey:@"PostCategory"];
	[parameters setObject:[NSNumber numberWithInteger:country] forKey:@"Country"];
	
	[self trackEvent:@"DeletePost" withParameters:parameters];
}

//13	NewComment	Prod/Dev	UserId	PostId			CommentId
+ (void)eventNewCommentWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withCommentId:(NSInteger)commentId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:commentId] forKey:@"CommentId"];
	
	[self trackEvent:@"NewComment" withParameters:parameters];
}

//14	DeleteComment	Prod/Dev	UserId	PostId			CommentId
+ (void)eventDeleteCommentWithUserId:(NSInteger)userId withPostId:(NSInteger)postId withCommentId:(NSInteger)commentId
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	[parameters setObject:[NSNumber numberWithInteger:postId] forKey:@"PostId"];
	[parameters setObject:[NSNumber numberWithInteger:commentId] forKey:@"CommentId"];
	
	[self trackEvent:@"DeleteComment" withParameters:parameters];
}

//15	Search	Prod/Dev	UserId	SearchQuery	SearchType
+ (void)eventSearchWithUserId:(NSInteger)userId withSearchQuery:(NSString *)searchQuery withSearchType:(NSString *)searchType
{
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSNumber numberWithInteger:userId] forKey:@"UserId"];
	if (searchQuery)  [parameters setObject:searchQuery forKey:@"SearchQuery"];
	if (searchType)  [parameters setObject:searchType forKey:@"SearchType"];
	//top / hashtags / people
	
	[self trackEvent:@"Search" withParameters:parameters];
}


#pragma mark - Errors

//Error Id		Error message
//1	ErrorPostDelete		Delete post failed
+ (void)errorPostDelete:(NSError *)error
{
	[self trackError:@"ErrorPostDelete" withMessage:@"Delete post failed" withError:error];
}

//2	ErrorFollow		Follow failed
+ (void)errorFollow:(NSError *)error
{
	[self trackError:@"ErrorFollow" withMessage:@"Follow failed" withError:error];
}

//3	ErrorLike		Like failed
+ (void)errorLike:(NSError *)error
{
	[self trackError:@"ErrorLike" withMessage:@"Like failed" withError:error];
}

//4	ErrorLogin		Login failed
+ (void)errorLogin:(NSError *)error
{
	[self trackError:@"ErrorLogin" withMessage:@"Login failed" withError:error];
}

//5	ErrorResetPassword		Reset password failed
+ (void)errorResetPassword:(NSError *)error
{
	[self trackError:@"ErrorResetPassword" withMessage:@"Reset password failed" withError:error];
}

//6	ErrorRegistration		Registration failed
+ (void)errorRegistration:(NSError *)error
{
	[self trackError:@"ErrorRegistration" withMessage:@"Registration failed" withError:error];
}

//7	ErrorCommentDelete		Delete comment failed
+ (void)errorCommentDelete:(NSError *)error
{
	[self trackError:@"ErrorCommentDelete" withMessage:@"Delete comment failed" withError:error];
}

//8	ErrorAddEnergy		Add Energy failed
+ (void)errorAddEnergy:(NSError *)error
{
	[self trackError:@"ErrorAddEnergy" withMessage:@"Add Energy failed" withError:error];
}

//9	ErrorMailSend		Mail send failed
+ (void)errorMailSend:(NSError *)error
{
	[self trackError:@"ErrorMailSend" withMessage:@"Mail send failed" withError:error];
}

//10	ErrorPostCategory		Post category response failed
+ (void)errorPostCategory:(NSError *)error
{
	[self trackError:@"ErrorPostCategory" withMessage:@"Post category response failed" withError:error];
}

//11	ErrorChangePassword		Change password failed
+ (void)errorChangePassword:(NSError *)error
{
	[self trackError:@"ErrorChangePassword" withMessage:@"Change password failed" withError:error];
}

//12	ErrorProfileEdit		Edit profile failed
+ (void)errorProfileEdit:(NSError *)error
{
	[self trackError:@"ErrorProfileEdit" withMessage:@"Edit profile failed" withError:error];
}

//13	ErrorSearchResponse		Search response error
+ (void)errorSearchResponse:(NSError *)error
{
	[self trackError:@"ErrorSearchResponse" withMessage:@"Search response error" withError:error];
}

//14	ErrorMainUpdateUser		User update failed
+ (void)errorMainUpdateUser:(NSError *)error
{
	[self trackError:@"ErrorMainUpdateUser" withMessage:@"User update failed" withError:error];
}

//15	ErrorMainGetCountryList		Get country list failed
+ (void)errorMainGetCountryList:(NSError *)error
{
	[self trackError:@"ErrorMainGetCountryList" withMessage:@"Get country list failed" withError:error];
}

@end
