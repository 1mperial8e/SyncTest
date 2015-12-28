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
	if (![defaults objectForKey:@"Denmark"]) {
		NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
		NSInteger index = 1;
		for (NSString *checkCountry in self.countries) {
			if ([checkCountry isEqualToString:country]) {
				[defaults setObject:[NSNumber numberWithLong:index] forKey:checkCountry];
			} else {
				[defaults setObject:@0 forKey:checkCountry];
			}
			index++;
		}		
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
		numericState = [NSNumber numberWithInteger:index + 1];
	} else {
		numericState = [NSNumber numberWithInteger:0];
	}
	self.countriesEnabledState[index] = numericState;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *countryKey = self.countries[index];
	[defaults setObject:numericState forKey:countryKey];
	[defaults synchronize];
}

- (NSInteger) getEnabledCountriesCount
{
	NSInteger enabledCountriesCount = 0;
	for (NSNumber *countryState in self.countriesEnabledState)
	{
		if (![countryState isEqualToNumber:@0]) {
			enabledCountriesCount++;
		}
	}
	return enabledCountriesCount;
}

- (NSString *) getEnabledCountriesStringID
{
	NSString *enabledCountriesStringID = @"";
	for (NSNumber *countryState in self.countriesEnabledState)
	{
		if (![countryState isEqualToNumber:@0]) {
			if (enabledCountriesStringID.length != 0) {
				enabledCountriesStringID = [enabledCountriesStringID stringByAppendingString:@","];
			}
			NSString *currentID = [NSString stringWithFormat:@"%@",countryState];
			enabledCountriesStringID = [enabledCountriesStringID stringByAppendingString:currentID];
		}
	}
	return enabledCountriesStringID;
}

@end
