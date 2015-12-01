//
//  WLIAnalytics.h
//  MyDrive
//
//  Created by Roman R on 01.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Flurry.h"

@interface WLIAnalytics : NSObject

+ (void) trackEvent:(NSString *)eventName withParameters:(NSDictionary *)params;
+ (void) setUserID:(NSString *) userID;
+ (void) startSession;

@end
