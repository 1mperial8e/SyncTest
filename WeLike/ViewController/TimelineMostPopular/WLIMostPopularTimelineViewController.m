//
//  WLIMostPopularTimelineViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIMostPopularTimelineViewController.h"
#import "WLITimelineSettingsViewController.h"
#import "WLICountrySettings.h"

@interface WLIMostPopularTimelineViewController ()

@end

@implementation WLIMostPopularTimelineViewController

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Most Popular";
	}
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChangedNotificationRecieved:) name:CountriesFilterSettingsChangeNotification object:nil];
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    if (reloadAll) {
        [self.loadTimelineOperation cancel];
    }
    loading = YES;
    if (reloadAll) {
        loadMore = YES;
    }
    NSUInteger page = reloadAll ? 1 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
	
	NSString *countriesStringId = [[WLICountrySettings sharedSettings] getEnabledCountriesStringID];
    self.loadTimelineOperation = [sharedConnect timelineForUserID:sharedConnect.currentUser.userID withCategory:15 countryID:countriesStringId searchString:@"" page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

#pragma mark - Actions

- (void)settingsButtonAction:(id)sender
{
	WLITimelineSettingsViewController *settingsViewController = [WLITimelineSettingsViewController new];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	navController.navigationBar.backgroundColor = [UIColor redColor];
    [[WLIUtils rootController] presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Notification

- (void)settingsChangedNotificationRecieved:(NSNotification *)notification
{
	[self reloadData:YES];
}

@end
