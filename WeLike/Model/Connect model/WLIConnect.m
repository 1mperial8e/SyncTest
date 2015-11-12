//
//  WLIConnect.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIConnect.h"

#define kBaseLink @"http://mydrive-rails-dev.appmedia.no/"

#define kAPIKey @"!#wli!sdWQDScxzczFžŽYewQsq_?wdX09612627364[3072∑34260-#"
#define kConnectionTimeout 30
#define kCompressionQuality 1.0f

//Server status responses
#define kOK @"OK"
#define kBAD_REQUEST @"BAD_REQUEST"
#define kNO_CONNECTION @"NO_CONNECTION"
#define kSERVICE_UNAVAILABLE @"SERVICE_UNAVAILABLE"
#define kPARTIAL_CONTENT @"PARTIAL_CONTENT"
#define kCONFLICT @"CONFLICT"
#define kUNAUTHORIZED @"UNAUTHORIZED"
#define kNOT_FOUND @"NOT_FOUND"
#define kUSER_CREATED @"USER_CREATED"
#define kUSER_EXISTS @"USER_EXISTS"
#define kLIKE_CREATED @"LIKE_CREATED"
#define kLIKE_EXISTS @"LIKE_EXISTS"
#define kFORBIDDEN @"FORBIDDEN"
#define kCREATED @"CREATED"

// UserDefaults
static NSString *const CurrentUserKey = @"_currentUser";
static NSString *const TokenKey = @"TokenKey";

// API parameters names
static NSString *const UsernameKey = @"username";
static NSString *const UserPasswordKey = @"password";

static NSString *const AuthTokenKey = @"token";

@interface WLIConnect ()

@property (strong, nonatomic) NSString *authToken;

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
    httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseLink]];
    [httpClient.requestSerializer setValue:kAPIKey forHTTPHeaderField:@"api_key"];
    httpClient.responseSerializer = [AFJSONResponseSerializer serializer];
    json = [[SBJsonParser alloc] init];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _dateOnlyFormatter = [[NSDateFormatter alloc] init];
    [_dateOnlyFormatter setDateFormat:@"MM/dd/yyyy"];
    [_dateOnlyFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
}

#pragma mark - Accessors

- (void)setAuthToken:(NSString *)authToken
{
    _authToken = authToken;
    if (authToken) {
        [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:AuthTokenKey];
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
        NSDictionary *parameters = @{UsernameKey : username, UserPasswordKey : password, AuthTokenKey : self.authToken};
        [httpClient POST:@"api/login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.authToken = [responseObject objectForKey:AuthTokenKey];
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            _currentUser = [WLIUser initWithDictionary:rawUser];
            [self saveCurrentUser];
            if (completion) {
                completion(_currentUser, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/login" dataLog:error.localizedDescription];
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
    _currentUser = nil;
    [self removeCurrentUser];
}

- (void)registerUserWithUsername:(NSString *)username
                        password:(NSString *)password
                           email:(NSString *)email
                      userAvatar:(UIImage *)userAvatar
                        userType:(int)userType
                    userFullName:(NSString *)userFullName
                        userInfo:(NSString *)userInfo
                    onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion
{
    if (!username.length || !password.length || !email.length || !userFullName.length) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSDictionary *parameters = @{UsernameKey : username,
                                     UserPasswordKey : password,
                                     @"email" : email,
                                     @"userFullname" : userFullName,
                                     @"userTypeID" : @(userType),
                                     @"userInfo" : userInfo ? userInfo : @""};
        [httpClient POST:@"api/register" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (userAvatar) {
                NSData *imageData = UIImageJPEGRepresentation(userAvatar, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"userAvatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            _currentUser = [WLIUser initWithDictionary:rawUser];
            [self saveCurrentUser];
            if (completion) {
                completion(_currentUser, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/register" dataLog:error.localizedDescription];
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

- (void)userWithUserID:(NSInteger)userID onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        if (completion) {
            completion(nil, BAD_REQUEST);
        }
    } else {
        NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%zd", self.currentUser.userID],
                                     @"forUserID": [NSString stringWithFormat:@"%zd", userID],
                                     AuthTokenKey : self.authToken};
        [httpClient POST:@"api/getProfile" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
            [self debugger:parameters.description methodLog:@"api/getProfile" dataLog:error.localizedDescription];
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
                   userEmail:(NSString *)userEmail
                    password:(NSString *)password
                  userAvatar:(UIImage *)userAvatar
                userFullName:(NSString *)userFullName
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
        if (userEmail.length) {
            [parameters setObject:userEmail forKey:@"email"];
        }
        if (password.length) {
            [parameters setObject:password forKey:@"password"];
        }
        if (userFullName.length) {
            [parameters setObject:userFullName forKey:@"userFullname"];
        }
        if (userInfo.length) {
            [parameters setObject:userInfo forKey:@"userInfo"];
        }
        [parameters setObject:self.authToken forKey:AuthTokenKey];
        
        [httpClient POST:@"api/setProfile" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
            [self debugger:parameters.description methodLog:@"api/setProfile" dataLog:error.localizedDescription];
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

- (void)newUsersWithPageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion
{
    NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%zd", self.currentUser.userID],
                                 @"take": [NSString stringWithFormat:@"%zd", pageSize],
                                 AuthTokenKey : self.authToken};
    [httpClient POST:@"api/getNewUsers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = [responseObject objectForKey:@"items"];
        NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
        if (completion) {
            completion([users mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getNewUsers" dataLog:error.localizedDescription];
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

        [httpClient POST:@"api/findUsers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = [responseObject objectForKey:@"items"];
            NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
            if (completion) {
                completion([users mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/findUsers" dataLog:error.localizedDescription];
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

#pragma mark - Timeline

- (void)timelineForUserID:(NSInteger)userID
                     page:(NSInteger)page
                 pageSize:(NSInteger)pageSize
             onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;
{
    
    [self timelineForUserID:userID withCategory:0 page:page pageSize:pageSize onCompletion:completion];
}

- (void)timelineForUserID:(NSInteger)userID
             withCategory:(NSInteger)categoryID
                     page:(NSInteger)page
                 pageSize:(NSInteger)pageSize
             onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
    [self timelineForUserID:userID withCategory:categoryID countryID:0 searchString:@"" page:page pageSize:pageSize onCompletion:completion];
}

- (void)timelineForUserID:(NSInteger)userID
             withCategory:(NSInteger)categoryID
                countryID:(NSInteger)countryID
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
        [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"forUserID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", categoryID] forKey:@"categoryID"];
        [parameters setObject:[NSString stringWithFormat:@"%zd", countryID] forKey:@"countryID"];
        [parameters setObject:[NSString stringWithFormat:@"%@", searchString] forKey:@"searchstring"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [httpClient POST:@"api/getTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
            if (completion) {
                completion([posts mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getTimeline" dataLog:error.localizedDescription];
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
        [parameters setObject:@"0" forKey:@"categoryID"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [httpClient POST:@"api/getConnectTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
            if (completion) {
                completion([posts mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getConnectTimeline" dataLog:error.localizedDescription];
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
                    onCompletion:(void (^)(NSMutableArray *posts, WLIUser *user, ServerResponse serverResponseCode))completion
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

        [httpClient POST:@"api/getMydriveTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            WLIUser *user = [WLIUser initWithDictionary:[responseObject objectForKey:@"user"]];
            NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
            if (completion) {
                completion([posts mutableCopy], user, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getMydriveTimeline" dataLog:error.localizedDescription];
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
        [parameters setObject:postText ? postText : @"" forKey:@"postText"];
        [parameters setObject:countries ? countries : @"0" forKey:@"countries"];
        [parameters setObject:postKeywords ? postKeywords : @[] forKey:@"postKeywords"];
        [parameters setObject:postCategory forKey:@"postCategory"];
        [parameters setObject:self.authToken forKey:AuthTokenKey];

        [httpClient POST:@"api/sendPost" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
            if (completion) {
                completion(post, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/getRecentPosts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawPosts = [responseObject objectForKey:@"items"];
        NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
        if (completion) {
            completion([posts mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getRecentPosts" dataLog:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

- (void)popularPostsOnPage:(NSInteger)page pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [httpClient POST:@"api/getPopularPosts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawPosts = [responseObject objectForKey:@"items"];
        NSArray *posts = [WLIPost arrayWithDictionariesArray:rawPosts];
        if (completion) {
            completion([posts mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getPopularPosts" dataLog:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

- (void)deletePostID:(NSInteger)postID onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%zd", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", postID] forKey:@"postID"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [httpClient POST:@"api/deletePost" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/deletePost" dataLog:error.localizedDescription];
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

        [httpClient POST:@"api/setComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawComment = [responseObject objectForKey:@"item"];
            WLIComment *comment = [WLIComment initWithDictionary:rawComment];
            if (completion) {
                completion(comment, OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/setComment" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/removeComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeComment" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/getComments" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawComments = [responseObject objectForKey:@"items"];
        NSArray *comments = [WLIComment arrayWithDictionariesArray:rawComments];
        if (completion) {
            completion([comments mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getComments" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/setLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawLike = [responseObject objectForKey:@"item"];
        WLILike *like = [WLILike initWithDictionary:rawLike];
        if (completion) {
            completion(like, OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/setLike" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/removeLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeLike" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/getLikes" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawLikes = [responseObject objectForKey:@"items"];
        NSArray *likes = [WLILike arrayWithDictionariesArray:rawLikes];
        if (completion) {
            completion([likes mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getLikes" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/setFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        WLIFollow *follow = [WLIFollow initWithDictionary:rawFollow];
        self.currentUser.followingCount++;
        if (completion) {
            completion(follow, OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/setFollow" dataLog:error.localizedDescription];
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

    [httpClient POST:@"api/removeFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.currentUser.followingCount--;
        if (completion) {
            completion(OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeFollow" dataLog:error.localizedDescription];
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

        [httpClient POST:@"api/getFollowers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = responseObject[@"items"];
            NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
            if (completion) {
                completion([users mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getFollowers" dataLog:error.localizedDescription];
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

        [httpClient POST:@"api/getFollowing" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = responseObject[@"items"];
            NSArray *users = [WLIUser arrayWithDictionariesArray:rawUsers];
            if (completion) {
                completion([users mutableCopy], OK);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getFollowing" dataLog:error.localizedDescription];
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

#pragma mark - Hashtags

- (void)hashtagsInSearch:(NSString *)searchString pageSize:(NSInteger)pageSize onCompletion:(void (^)(NSMutableArray *hashtags, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%@", searchString ? searchString : @""] forKey:@"searchstring"];
    [parameters setObject:[NSString stringWithFormat:@"%zd", pageSize] forKey:@"take"];
    [parameters setObject:self.authToken forKey:AuthTokenKey];

    [httpClient POST:@"api/getPoplularHashtags" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawHashtags = responseObject[@"items"];
        NSArray *hashtags = [WLIHashtag arrayWithDictionariesArray:rawHashtags];
        if (completion) {
            completion([hashtags mutableCopy], OK);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getPoplularHashtags" dataLog:error.localizedDescription];
        if (completion) {
            if (operation.response) {
                completion(nil, (ServerResponse)operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }
    }];
}

#pragma mark - debugger

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLog:(NSString *)data {
    
#ifdef DEBUG
    NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, (NSDictionary *) [json objectWithString:data]);
#else
#endif
}

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLogFormatted:(NSString *)data {
    
#ifdef DEBUG
    NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, data);
#else
#endif
}

@end
