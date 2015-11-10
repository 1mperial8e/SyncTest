//
//  WLIInfoPageViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 16/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIInfoPageViewController.h"
#import "WLIInfoWhyViewController.h"
#import "WLICategoryPostsViewController.h"

@interface WLIInfoPageViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *insetView;
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;

@end

@implementation WLIInfoPageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"What is MyDrive?";
    self.scrollView.contentSize = CGSizeMake(375, 1116);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.insetView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, CGRectGetMaxY(self.insetView.frame));
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, CGRectGetMaxY(self.insetView.frame));
}

#pragma mark - Actions

- (IBAction)marketButtonTouchUpInside:(id)sender
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"Market";
    categoryViewController.categoryID = 1;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (IBAction)customerButtonTouchUpInside:(id)sender
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"Customer";
    categoryViewController.categoryID = 4;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (IBAction)capabilityButtonTouchUpInside:(id)sender
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"Capabilities";
    categoryViewController.categoryID = 2;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (IBAction)peopleButtonTouchUpInside:(id)sender
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"People";
    categoryViewController.categoryID = 8;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (IBAction)whyButtonTouchUpInside:(id)sender
{
    WLIInfoWhyViewController *myViewController = [WLIInfoWhyViewController new];
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (IBAction)buttonPlayVideoTouchUpInside:(id)sender
{
    MPMoviePlayerViewController *movieController;
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"director" withExtension:@"mov"];
    movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self presentViewController:movieController animated:YES completion:nil];
    [movieController.moviePlayer play];
}

#pragma mark - Load Data

- (void)reloadData:(BOOL)reloadAll
{
    // dumny
}

@end

