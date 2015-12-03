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

@end
