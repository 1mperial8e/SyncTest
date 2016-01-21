//
//  WLIStartPageViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 12/28/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIStartPageViewController.h"
#import "WLIInfoWhyViewController.h"
#import "WLIInfoPageViewController.h"

@interface WLIStartPageViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *whatIsMyDriveButton;
@property (weak, nonatomic) IBOutlet UIButton *agoraButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@end

@implementation WLIStartPageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"MyDrive";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_email"] style:UIBarButtonItemStylePlain target:self action:@selector(sendFeedBack:)];
    self.whatIsMyDriveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.agoraButton.layer.borderColor = [UIColor colorWithWhite:255 alpha:0.5].CGColor;
    self.whatIsMyDriveButton.layer.borderWidth = 1;
    self.agoraButton.layer.borderWidth = 1;
    
    CGFloat height = [UIScreen mainScreen].bounds.size.width * /*3.35f*/ 2.35;
    self.contentHeightConstraint.constant = height;
}

#pragma mark - Actions

- (IBAction)whyButtonTouchUpInside:(id)sender
{
    WLIInfoWhyViewController *myViewController = [WLIInfoWhyViewController new];
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (IBAction)whatIsMyDriveButtonAction:(id)sender
{
    WLIInfoPageViewController *infoViewController = [WLIInfoPageViewController new];
    [self.navigationController pushViewController:infoViewController animated:YES];
}

- (IBAction)playVideoButtonAction:(id)sender
{
    MPMoviePlayerViewController *movieController;
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"promo" withExtension:@"mov"];
    movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self presentViewController:movieController animated:YES completion:nil];
    [movieController.moviePlayer play];
}

- (IBAction)agoraButtonAction:(id)sender
{
    [WLIUtils showWebViewControllerWithUrl:[NSURL URLWithString:@"http://www.santander.co.uk"]];
}

- (IBAction)digitalWeekButtonAction:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Digital week" message:@"Coming soon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (IBAction)websiteButtonAction:(id)sender
{
    [WLIUtils showWebViewControllerWithUrl:[NSURL URLWithString:@"http://www.tourdesfjords.no"]];
}

@end
