//
//  WLIUtils.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

static NSString *const CustomLinkAttributeName = @"CustomLinkAttributeName";

@interface WLIUtils : NSObject

#pragma mark - String
+ (NSAttributedString *)formattedString:(NSString *)string WithHashtagsAndUsers:(NSArray *)taggedUsers;
+ (BOOL)isValidEmail:(NSString *)email UseHardFilter:(BOOL)filter;
+ (BOOL)isValidUserName:(NSString *)userName;

#pragma mark - Controllers
+ (void)showWebViewControllerWithUrl:(NSURL *)url;
+ (UIViewController *)rootController;

@end
