//
//  WLIUtils.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIUtils.h"
#import "WLIWebViewController.h"
#import "WLIAppDelegate.h"

@implementation WLIUtils

#pragma mark - String

+ (NSAttributedString *)formattedString:(NSString *)string WithHashtagsAndUsers:(NSArray *)taggedUsers
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string ? string : @""
                                                                                         attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.75 alpha:1]}];
    NSSet *endHashtagCharachters = [NSSet setWithObjects:@" ", @".", @"-", @"!", @"?", @"[", @"]", @"@", @"#", @"$", @"%", @"^", @"&", @"*", @"(", @")", @"+", @"=", @"/", @"|", @"/", nil];
    for (int i = 0; i < attributedString.length; i++) {
        unichar charachter = [attributedString.string characterAtIndex:i];
        if (charachter == '#' || charachter == '@') {
            BOOL isUserTag = charachter == '@';
            for (int j = i + 1; j < attributedString.length; j++) {
                unichar nextCharachter = [attributedString.string characterAtIndex:j];
                if (j == attributedString.length - 1 && ![endHashtagCharachters containsObject:[NSString stringWithFormat:@"%c", nextCharachter]]) {
                    // end of text
                    if (isUserTag) {
                        NSString *user = [string substringWithRange:NSMakeRange(i + 1, j - i)];
                        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"username LIKE %@", user];
                        if (![taggedUsers filteredArrayUsingPredicate:namePredicate].count) {
                            break;
                        }
                    }
                    [attributedString addAttribute:CustomLinkAttributeName value:@"LINK" range:NSMakeRange(i, j - i + 1)];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(i, j - i + 1)];
                    break;
                }
                if ([endHashtagCharachters containsObject:[NSString stringWithFormat:@"%c", nextCharachter]]) {
                    if (j == i + 1) { // only #, @
                        break;
                    }
                    if (isUserTag) {
                        NSString *user = [string substringWithRange:NSMakeRange(i + 1, j - i - 1)];
                        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"username LIKE %@", user];
                        if (![taggedUsers filteredArrayUsingPredicate:namePredicate].count) {
                            break;
                        }
                    }
                    
                    // end of hashtag
                    [attributedString addAttribute:CustomLinkAttributeName value:@"LINK" range:NSMakeRange(i, j - i)];
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(i, j - i)];
                    i = j;
                    break;
                }
            }
        }
    }
    
    return attributedString;
}

+ (BOOL)isValidEmail:(NSString *)email UseHardFilter:(BOOL)filter
{
    BOOL stricterFilter = filter;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@{1}([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidUserName:(NSString *)userName
{
    NSString *allowedSymbols = @"[A-Za-z0-9-]+";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", allowedSymbols];
    return [test evaluateWithObject:userName];
}

#pragma mark - Controllers

+ (void)showWebViewControllerWithUrl:(NSURL *)url
{
    WLIWebViewController *webViewController = [[WLIWebViewController alloc] initWithUrl:url];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self.rootController presentViewController:navController animated:YES completion:nil];
}

+ (UIViewController *)rootController
{
    WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.tabBarController;
}

@end
