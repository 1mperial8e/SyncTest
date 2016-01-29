//
//  WLIConnect.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIConnect.h"
#import "WLIAnalytics.h"

#define kBaseLinkDevelopement @"http://mydrive-rails-dev.appmedia.no/"
#define kBaseLinkProduction @"https://mydrive.financecorp.biz/"//@"https://mydrive-rails-prod.appmedia.no/"

#define kAPIKey @"!#wli!sdWQDScxzczFžŽYewQsq_?wdX09612627364[3072∑34260-#"
#define kConnectionTimeout 30
#define kCompressionQuality 1.0f

// UserDefaults
static NSString *const CurrentUserKey = @"_currentUser";
static NSString *const TokenKey = @"TokenKey";

// API parameters names
static NSString *const UsernameKey = @"username";
static NSString *const UserPasswordKey = @"password";

static NSString *const AuthTokenKey = @"token";

@interface WLIConnect ()

@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpClient;
@property (strong, nonatomic) SBJsonParser *jsonParser;

@end

@implementation WLIConnect

@synthesize authToken = _authToken;

#pragma mark - Singleton

+ (instancetype)sharedConnect
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
        [self loadUser];
        self.authToken = [[NSUserDefaults standardUserDefaults] objectForKey:TokenKey];
    }
    return self;
}

#pragma mark - Setup

- (void)setupDefaults
{
    self.httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseLinkProduction]];
    self.httpClient.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.httpClient.responseSerializer = [AFJSONResponseSerializer serializer];
    self.jsonParser = [[SBJsonParser alloc] init];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _dateOnlyFormatter = [[NSDateFormatter alloc] init];
    [self.dateOnlyFormatter setDateFormat:@"MM/dd/yyyy"];
    [self.dateOnlyFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
}

#pragma mark - Accessors

- (void)setAuthToken:(NSString *)authToken
{
    _authToken = authToken;
    if (authToken) {
        [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:TokenKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)authToken
{
    if (_authToken) {
        return _authToken;
    }
    return @"";
}

#pragma mark - User

- (void)loadUser
{
    NSData *archivedUser = [[NSUserDefaults standardUserDefaults] objectForKey:CurrentUserKey];
    if (archivedUser) {
        self.currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:archivedUser];
    }
}

- (void)saveCurrentUser
{
    if (self.currentUser) {
        NSData *archivedUser = [NSKeyedArchiver archivedDataWithRootObject:_currentUser];
        [[NSUserDefaults standardUserDefaults] setObject:archivedUser forKey:CurrentUserKey];
    }
}

- (void)removeCurrentUser
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CurrentUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UserAPI

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion
{
    if (!username.length || !password.length) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSDictionary *parameters = @{UsernameKey : username, UserPasswordKey : password};
        [self.httpClient POST:@"api/login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.authToken = [responseObject objectForKey:AuthTokenKey];
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            _currentUser = [WLIUser initWithDictionary:rawUser];
            [self saveCurrentUser];
			[WLIAnalytics eventLoginWithUser:self.currentUser];
            if (completion) {
                completion(_currentUser, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[WLIAnalytics eventLoginFailedWithStatusCode:operation.response.statusCode withUserName:username withErrorMessage:error.localizedDescription];
			[self debugger:parameters.description methodLog:@"api/login" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

- (void)logout
{
	[WLIAnalytics eventLogoutWithUser:self.currentUser];
    _currentUser = nil;
    [self removeCurrentUser];
}

- (void)registerUserWithUsername:(NSString *)username
                        password:(NSString *)password
                           email:(NSString *)email
                      userAvatar:(UIImage *)userAvatar
                        userType:(int)userType
                    userFullName:(NSString *)userFullName
					   userTitle:(NSString *)userTitle
				  userDepartment:(NSString *)userDepartment
                        userInfo:(NSString *)userInfo
                    onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion
{
    if (!username.length || !password.length || !email.length || !userFullName.length) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary: @{UsernameKey : username,
                                     UserPasswordKey : password,
                                     @"email" : email,
                                     @"userFullname" : userFullName,
                                     @"userTypeID" : @(userType),
                                     @"userInfo" : userInfo ? userInfo : @""}];
		if (userTitle.length) {
			[parameters setObject:userTitle forKey:@"userTitle"];
		}
		if (userDepartment.length) {
			[parameters setObject:userDepartment forKey:@"userDepartment"];
		}

        [self.httpClient POST:@"api/register" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (userAvatar) {
                NSData *imageData = UIImageJPEGRepresentation(userAvatar, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"userAvatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.authToken = [responseObject objectForKey:AuthTokenKey];
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            _currentUser = [WLIUser initWithDictionary:rawUser];
            [self saveCurrentUser];
			[WLIAnalytics eventRegistrationWithUser:self.currentUser];
            if (completion) {
                completion(_currentUser, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[WLIAnalytics eventRegistrationFailedWithStatusCode:operation.response.statusCode withUserName:username withUserFullName:userFullName withUserEmail:email withErrorMessage:error.localizedDescription];
            [self debugger:parameters.description methodLog:@"api/register" dataLogFormatted:error.localizedDescription];
            if (completion) {
				if (operation.response) {
					NSData *errorJsonData = [[operation.responseObject objectForKey:@"error"] dataUsingEncoding:NSUTF8StringEncoding];
                    if (errorJsonData) {
                        NSError *jsonError;
                        NSDictionary *errorsDictionary = [NSJSONSerialization JSONObjectWithData:errorJsonData options:NSJSONReadingMutableContainers  error:&jsonError];
                        if ([[errorsDictionary objectForKey:@"username"] firstObject] ) {
                            completion(nil, USERNAME_EXISTS);
                        } else  {
                            completion(nil, (ServerResponse)operation.response.statusCode);
                        }
                    } else {
                        completion(nil, (ServerResponse)operation.response.statusCode);
                    }
                } else {
					completion(nil, NO_CONNECTION);
				}
            }
        }];
    }
}

- (void)userWithUserID:(NSInteger)userID onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%zd", userID],
                                     @"forUserID": [NSString stringWithFormat:@"%zd", self.currentUser.userID],
                                     AuthTokenKey : self.authToken};
        [self.httpClient POST:@"api/getProfile" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            WLIUser *user = [WLIUser initWithDictionary:rawUser];
            if (user.userID == _currentUser.userID) {
                _currentUser = user;
                [self saveCurrentUser];
            }
            if (completion) {
                completion(user, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getProfile" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

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
                onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userType] forKey:@"userTypeID"];
        if (userUsername.length) {
            [parameters setObject:userUsername forKey:@"username"];
        }
        if (userFullName.length) {
            [parameters setObject:userFullName forKey:@"userFullname"];
        }
		if (userTitle.length) {
			[parameters setObject:userTitle forKey:@"userTitle"];
		}
		if (userDepartment.length) {
			[parameters setObject:userDepartment forKey:@"userDepartment"];
		}
		[parameters setObject:userInfo forKey:@"userInfo"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];
        
        [self.httpClient POST:@"api/setProfile" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (userAvatar) {
                NSData *imageData = UIImageJPEGRepresentation(userAvatar, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"userAvatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            WLIUser *user = [WLIUser initWithDictionary:rawUser];
            self.currentUser = user;
            [self saveCurrentUser];
            if (completion) {
                completion(user, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[WLIAnalytics errorProfileEdit:error];
            [self debugger:parameters.description methodLog:@"api/setProfile" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

- (void)changePassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword withCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:oldPassword forKey:@"old_password"];
    [parameters setObject:newPassword forKey:@"password"];
    [parameters setObject:newPassword forKey:@"password_confirmation"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];
    [self.httpClient POST:@"api/changePassword" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/changePassword" dataLogFormatted:error.localizedDescription];
		[WLIAnalytics errorChangePassword:error];
        if (completion) {
            if (operation.response) {
                completion((ServerResponse)operation.response.statusCode);
            } else {
                completion(NO_CONNECTION);
            }
        }
    }];
}

- (void)newUsersWithPageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion
{
    NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%zd", self.currentUser.userID],
                                 @"take": [NSString stringWithFormat:@"%zd", pageSize],
                                 AuthTokenKey : self.authToken};
    [self.httpClient POST:@"api/getNewUsers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = [responseObject objectForKey:@"items"];
        NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
        if (completion) {
            completion([users mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getNewUsers" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

- (void)usersForSearchString:(NSString *)searchString
                        page:(NSInteger)page
                    pageSize:(NSInteger)pageSize
                onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion
{
    if (!searchString.length) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:searchString forKey:@"searchTerm"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [self.httpClient POST:@"api/findUsers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = [responseObject objectForKey:@"items"];
            NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
            if (completion) {
                completion([users mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/findUsers" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

- (void)forgotPasswordWithEmail:(NSString *)email onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    if (!email.length) {
        if (completion) {
            completion(BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:email forKey:@"email"];
        [self.httpClient POST:@"api/forgotPassword" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completion) {
                completion(OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[WLIAnalytics errorResetPassword:error];
            [self debugger:parameters.description methodLog:@"api/forgotPassword" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion((ServerResponse)operation.response.statusCode);
                } else {
                    completion(NO_CONNECTION);
                }
            }
        }];
    }
}

#pragma mark - Timeline

- (AFHTTPRequestOperation *)timelineForUserID:(NSInteger)userID
                     page:(NSInteger)page
                 pageSize:(NSInteger)pageSize
             onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;
{
    
   return [self timelineForUserID:userID withCategory:0 page:page pageSize:pageSize onCompletion:completion];
}

- (AFHTTPRequestOperation *)timelineForUserID:(NSInteger)userID
             withCategory:(NSInteger)categoryID
                     page:(NSInteger)page
                 pageSize:(NSInteger)pageSize
             onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
   return [self timelineForUserID:userID withCategory:categoryID countryID:0 searchString:@"" page:page pageSize:pageSize onCompletion:completion];
}

- (AFHTTPRequestOperation *)timelineForUserID:(NSInteger)userID
                                 withCategory:(NSInteger)categoryID
                                    countryID:(NSString *)countryID
                                 searchString:(NSString *)searchString
                                         page:(NSInteger)page
                                     pageSize:(NSInteger)pageSize
                                 onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"forUserID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", categoryID] forKey:@"categoryID"];
        [parameters setObject:countryID forKey:@"countryID"];
        [parameters setObject:[NSString stringWithFormat:@"%@", [searchString lowercaseString]] forKey:@"searchstring"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        AFHTTPRequestOperation *operation = [self.httpClient POST:@"api/getTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
            if (completion) {
                completion([posts mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if (operation.response) {
				[WLIAnalytics errorPostCategory:error];
			}
            [self debugger:parameters.description methodLog:@"api/getTimeline" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
        return operation;
    }
    return nil;
}

- (void)connectTimelineForUserID:(NSInteger)userID
                            page:(NSInteger)page
                        pageSize:(NSInteger)pageSize
                    onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"forUserID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
        [parameters setObject:@"15" forKey:@"categoryID"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [self.httpClient POST:@"api/getConnectTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
            if (completion) {
                completion([posts mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getConnectTimeline" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

- (void)mydriveTimelineForUserID:(NSInteger)userID
                            page:(NSInteger)page
                        pageSize:(NSInteger)pageSize
                    onCompletion:(void (^)(NSMutableArray *posts, id rankInfo, ServerResponse serverResponseCode))completion
{
    
    if (userID < 1) {
        if (completion) {
            completion(nil, nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"forUserID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [self.httpClient POST:@"api/getMydriveTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
            NSDictionary *rankInfo = [responseObject objectForKey:@"scoreboard"];
            
            if (completion) {
                completion([posts mutableCopy], rankInfo, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getMydriveTimeline" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, nil, NO_CONNECTION);
                }
            }
        }];
    }
}

#pragma mark - Posts

- (void)sendPostWithCountries:(NSString *)countries
                     postText:(NSString *)postText
                 postKeywords:(NSArray *)postKeywords
                 postCategory:(NSNumber *)postCategory
                    postImage:(UIImage *)postImage
                 onCompletion:(void (^)(WLIPost *post, ServerResponse serverResponseCode))completion
{
    [self sendPostWithCountries:countries
                       postText:postText
                   postKeywords:postKeywords
                   postCategory:postCategory
                      postImage:postImage
                      postVideo:nil
                   onCompletion:completion];
}

- (void)sendPostWithCountries:(NSString *)countries
                     postText:(NSString *)postText
                 postKeywords:(NSArray *)postKeywords
                 postCategory:(NSNumber *)postCategory
                    postImage:(UIImage *)postImage
                    postVideo:(NSData *)postVideoData
                 onCompletion:(void (^)(WLIPost *post, ServerResponse serverResponseCode))completion
{
    if (!postVideoData && !postImage && !postText) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
        if (postText) {
            [parameters setObject:postText forKey:@"postText"];
        }
        [parameters setObject:countries ? countries : @"0" forKey:@"countries"];
        [parameters setObject:postKeywords ? postKeywords : @[] forKey:@"postKeywords"];
        [parameters setObject:postCategory forKey:@"postCategory"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [self.httpClient POST:@"api/sendPost" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (postImage) {
                NSData *imageData = UIImageJPEGRepresentation(postImage, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"postImage" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
            if (postVideoData) {
                [formData appendPartWithFileData:postVideoData name:@"postVideo" fileName:@"video.mov" mimeType:@"video/mov"];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawPost = [responseObject objectForKey:@"item"];
            WLIPost *post = [WLIPost initWithDictionary:rawPost];
			[[NSNotificationCenter defaultCenter] postNotificationName:NewPostNotification object:self userInfo:@{@"newPost" : post}];

			[WLIAnalytics eventNewPostWithUserId:self.currentUser.userID withPost:post withPostCategory:post.postCategoryID withPostCountry:0];
//set proper country id

			if (completion) {
                completion(post, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[WLIAnalytics errorAddEnergy:error];
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

- (void)recentPostsWithPageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/getRecentPosts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawPosts = [responseObject objectForKey:@"items"];
        NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
        if (completion) {
            completion([posts mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getRecentPosts" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

- (AFHTTPRequestOperation *)popularPostsOnPage:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"forUserID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    AFHTTPRequestOperation *operation = [self.httpClient POST:@"api/getPopularPosts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawPosts = [responseObject objectForKey:@"items"];
        NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
        if (completion) {
            completion([posts mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getPopularPosts" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
    return operation;
}

- (void)deletePostID:(NSInteger)postID onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/deletePost" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(OK);
        }
		[[NSNotificationCenter defaultCenter] postNotificationName:PostDeletedNotification object:nil userInfo:@{@"postId" : @(postID), @"deleted" : @YES}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[WLIAnalytics errorPostDelete:error];
        [self debugger:parameters.description methodLog:@"api/deletePost" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion((ServerResponse)operation.response.statusCode);
            } else {
                completion(NO_CONNECTION);
            }
        }
    }];
}

#pragma mark - Comments

- (void)sendCommentOnPostID:(NSInteger)postID withCommentText:(NSString *)commentText onCompletion:(void (^)(WLIComment *comment, ServerResponse serverResponseCode))completion
{
    if (!commentText.length) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
        [parameters setObject:commentText forKey:@"commentText"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [self.httpClient POST:@"api/setComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawComment = [responseObject objectForKey:@"item"];
            WLIComment *comment = [WLIComment initWithDictionary:rawComment];
			[WLIAnalytics eventNewCommentWithUserId:self.currentUser.userID withPostId:postID withCommentId:comment.commentID];
            if (completion) {
                completion(comment, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/setComment" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

- (void)removeCommentWithCommentID:(NSInteger)commentID onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", commentID] forKey:@"commentID"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/removeComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[WLIAnalytics errorCommentDelete:error];
        [self debugger:parameters.description methodLog:@"api/removeComment" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion((ServerResponse)operation.response.statusCode);
            } else {
                completion(NO_CONNECTION);
            }
        }
    }];
}

- (void)commentsForPostID:(NSInteger)postID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *comments, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/getComments" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawComments = [responseObject objectForKey:@"items"];
        NSArray *comments = [WLIComment arrayWithDictionariesArray:rawComments];
        if (completion) {
            completion([comments mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getComments" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

#pragma mark - Likes

- (void)setLikeOnPostID:(NSInteger)postID onCompletion:(void (^)(WLILike *like, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/setLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawLike = [responseObject objectForKey:@"item"];
        WLILike *like = [WLILike initWithDictionary:rawLike];	
        if (completion) {
            completion(like, OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[WLIAnalytics errorLike:error];
        [self debugger:parameters.description methodLog:@"api/setLike" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

- (void)removeLikeWithLikeID:(NSInteger)postID onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/removeLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {	
        if (completion) {
            completion(OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeLike" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion((ServerResponse)operation.response.statusCode);
            } else {
                completion(NO_CONNECTION);
            }
        }
    }];
}

- (void)likesForPostID:(NSInteger)postID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *likes, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/getLikes" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawLikes = [responseObject objectForKey:@"items"];
        NSArray *likes = [WLILike arrayWithDictionariesArray:rawLikes];
        if (completion) {
            completion([likes mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getLikes" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

- (void)likersForPostID:(NSInteger)postID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *likers, ServerResponse serverResponseCode))completion
{	
		NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
		[parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
		[parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
		[parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
		[parameters setObject:self.authToken forKey:AuthTokenKey];
		
		[self.httpClient POST:@"api/getLikes" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSArray *rawLikers = [responseObject objectForKey:@"items"];
			NSArray *likers = [WLIUser arrayWithDictionariesArray:rawLikers];
			if (completion) {
				completion([likers mutableCopy], OK);
			}
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self debugger:parameters.description methodLog:@"api/getLikes" dataLogFormatted:error.localizedDescription];
			if (completion) {
				if (operation.response) {
					completion(nil, (ServerResponse)operation.response.statusCode);
				} else {
					completion(nil, NO_CONNECTION);
				}
			}
		}];
}


#pragma mark - Follow

- (void)setFollowOnUserID:(NSInteger)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"followingID"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/setFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        WLIFollow *follow = [WLIFollow initWithDictionary:rawFollow];
		[WLIAnalytics eventFollowWithUserId:self.currentUser.userID forUserId:userID];
        self.currentUser.followingCount++;
        if (completion) {
            completion(follow, OK);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FollowerUserNotification object:nil userInfo:@{@"userId" : @(userID), @"followed" : @YES}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[WLIAnalytics errorFollow:error];
        [self debugger:parameters.description methodLog:@"api/setFollow" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

- (void)removeFollowWithFollowID:(NSInteger)followID onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", followID] forKey:@"followingID"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [self.httpClient POST:@"api/removeFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.currentUser.followingCount--;
		[WLIAnalytics eventUnfollowWithUserId:self.currentUser.userID forUserId:followID];
		if (completion) {
            completion(OK);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FollowerUserNotification object:nil userInfo:@{@"userId" : @(followID), @"followed" : @NO}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeFollow" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion((ServerResponse)operation.response.statusCode);
            } else {
                completion(NO_CONNECTION);
            }
        }
    }];
}

- (void)followersForUserID:(NSInteger)userID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *followers, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"userID"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [self.httpClient POST:@"api/getFollowers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = [responseObject[@"items"] valueForKey:@"user"];
            NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
            if (completion) {
                completion([users mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getFollowers" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

- (void)followingForUserID:(NSInteger)userID page:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *following, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"userID"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [self.httpClient POST:@"api/getFollowing" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = [responseObject[@"items"] valueForKey:@"user"];
            NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
            if (completion) {
                completion([users mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getFollowing" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion(nil, (ServerResponse)operation.response.statusCode);
                } else {
                    completion(nil, NO_CONNECTION);
                }
            }
        }];
    }
}

#pragma mark - Search

- (AFHTTPRequestOperation *)search:(NSString *)searchString term:(NSString *)searchTerm pageNumber:(NSInteger)pageNumber onCompletion:(void (^)(NSMutableArray *hashtags, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%@", searchString ? searchString : @""] forKey:@"searchstring"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", pageNumber] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", kDefaultPageSize] forKey:@"take"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];
    [parameters setObject:searchTerm forKey:@"result_type"];
    AFHTTPRequestOperation *operation = [self.httpClient POST:@"api/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[WLIAnalytics eventSearchWithUserId:self.currentUser.userID withSearchQuery:searchString withSearchType:searchTerm];
        NSMutableArray *items = [NSMutableArray array];
        if ([searchTerm isEqualToString:@"mix"]) {
            NSArray *result = responseObject[@"mix"];
            for (NSDictionary *dict in result) {
                if ([dict objectForKey:@"hashtagID"]) {
                    [items addObject:[WLIHashtag initWithDictionary:dict]];
                } else {
                    [items addObject:[WLIUser initWithDictionary:dict]];
                }
            }
        } else if ([searchTerm isEqualToString:@"user"]) {
            NSArray *result = responseObject[@"users"];
            [items addObjectsFromArray:[WLIUser arrayWithDictionariesArray:result]];
        } else if ([searchTerm isEqualToString:@"hashtag"]) {
            NSArray *result = responseObject[@"hashtags"];
            [items addObjectsFromArray:[WLIHashtag arrayWithDictionariesArray:result]];
        }
        if (completion) {
            completion(items, OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[WLIAnalytics errorSearchResponse:error];
        [self debugger:parameters.description methodLog:@"api/getPoplularHashtags" dataLogFormatted:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
    return operation;
}

#pragma mark - Email

- (void)sendEmailToRecipient:(NSString *)toRecipient withSubject:(NSString *)subject content:(NSString *)content onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    if (!toRecipient.length || (!subject.length && !content.length)) {
        if (completion) {
            completion(BAD_REQUEST);
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:toRecipient forKey:@"email"];
        [parameters setObject:subject forKey:@"subject"];
        [parameters setObject:content forKey:@"content"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];
        [self.httpClient POST:@"api/send_email" parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if (completion) {
                completion(OK);
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
			[WLIAnalytics errorMailSend:error];
            [self debugger:parameters.description methodLog:@"api/getPoplularHashtags" dataLogFormatted:error.localizedDescription];
            if (completion) {
                if (operation.response) {
                    completion((ServerResponse)operation.response.statusCode);
                } else {
                    completion(NO_CONNECTION);
                }
            }
        }];
    }
}

#pragma mark - debugger

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLog:(NSString *)data {
    
#ifdef DEBUG
    NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, (NSDictionary *) [self.jsonParser objectWithString:data]);
#else
#endif
}

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLogFormatted:(NSString *)data
{
#ifdef DEBUG
    NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, data);
#else
#endif
}

@end
