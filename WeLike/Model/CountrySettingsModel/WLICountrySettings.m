//
//  WLICountrySettings.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLICountrySettings.h"

@interface WLICountrySettings()

@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) NSMutableArray *countriesEnabledState;

@end

@implementation WLICountrySettings

#pragma mark - Singleton

+ (instancetype)sharedSource
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
		self.countries = @[@"Denmark", @"Finland", @"Norway", @"Sweden", @"Nordic"];
		self.countriesEnabledState = [NSMutableArray new];
		[self getCountriesState];
	}
	return self;
}

#pragma mark - Accessors

- (void)getCountriesState
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:@"Denmark"])
	{
		[defaults setObject:@1 forKey:@"Denmark"];
		[defaults setObject:@2 forKey:@"Finland"];
		[defaults setObject:@3 forKey:@"Norway"];
		[defaults setObject:@4 forKey:@"Sweden"];
		[defaults setObject:@5 forKey:@"Nordic"];
		[defaults synchronize];
	}
	for (NSInteger i = 0; i < self.countries.count; i++) {
		NSString *countryKey = self.countries[i];
		self.countriesEnabledState[i] = [defaults objectForKey:countryKey];
	}
}

- (void)setState:(BOOL)state forCountryIndex:(NSInteger)index
{
	NSNumber *numericState;
	if (state) {
		numericState = [NSNumber numberWithInteger: index + 1];
	} else {
		numericState = [NSNumber numberWithInteger: 0];
	}
	self.countriesEnabledState[index] = numericState;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *countryKey = self.countries[index];
	[defaults setObject:numericState forKey:countryKey];
	[defaults synchronize];
}

@end
