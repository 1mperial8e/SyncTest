//
//  WLIWelcomeViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIWelcomeViewController.h"

@interface WLIWelcomeViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageViewLogo;

@end

@implementation WLIWelcomeViewController

#pragma mark - Action methods

- (IBAction)buttonLoginTouchUpInside:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(showLogin)]) {
        [self.delegate showLogin];
    }
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender
{    
    if ([self.delegate respondsToSelector:@selector(showRegister)]) {
        [self.delegate showRegister];
    }
}

@end
