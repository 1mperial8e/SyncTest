//
//  WLIInfoPageViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 16/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIInfoPageViewController.h"
#import "WLIInfoMarketViewController.h"
#import "WLIInfoCustomerViewController.h"
#import "WLIInfoCapabilityViewController.h"
#import "WLIInfoPeopleViewController.h"
#import "WLIInfoWhyViewController.h"

#import "WLICategoryPostsViewController.h"

@interface WLIInfoPageViewController ()

@end

@implementation WLIInfoPageViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.title = @"Why 20 % by 2020?";
        self.title = @"What is MyDrive?";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    scrollView.contentSize = CGSizeMake(320, 1142);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)marketButtonTouchUpInside:(id)sender
{
//    WLIInfoMarketViewController *myViewController = [[WLIInfoMarketViewController alloc] initWithNibName:@"WLIInfoMarketViewController" bundle:nil];
//    [self.navigationController pushViewController:myViewController animated:YES];
    
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"Market"];
    categoryViewController.categoryID = 1;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
- (IBAction)customerButtonTouchUpInside:(id)sender
{
//    WLIInfoCustomerViewController *myViewController = [[WLIInfoCustomerViewController alloc] initWithNibName:@"WLIInfoCustomerViewController" bundle:nil];
//    [self.navigationController pushViewController:myViewController animated:YES];
    
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"Customer"];
    categoryViewController.categoryID = 3;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
- (IBAction)capabilityButtonTouchUpInside:(id)sender
{
//    WLIInfoCapabilityViewController *myViewController = [[WLIInfoCapabilityViewController alloc] initWithNibName:@"WLIInfoCapabilityViewController" bundle:nil];
//    [self.navigationController pushViewController:myViewController animated:YES];
    
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"Capabilities"];
    categoryViewController.categoryID = 2;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
- (IBAction)peopleButtonTouchUpInside:(id)sender
{
//    WLIInfoPeopleViewController *myViewController = [[WLIInfoPeopleViewController alloc] initWithNibName:@"WLIInfoPeopleViewController" bundle:nil];
//    [self.navigationController pushViewController:myViewController animated:YES];
    
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"People"];
    categoryViewController.categoryID = 4;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
- (IBAction)whyButtonTouchUpInside:(id)sender
{
    WLIInfoWhyViewController *myViewController = [[WLIInfoWhyViewController alloc] initWithNibName:@"WLIInfoWhyViewController" bundle:nil];
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (IBAction)buttonPlayVideoTouchUpInside:(id)sender {
    MPMoviePlayerViewController *movieController;
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource: @"director" withExtension:@"mov"];
    movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self presentViewController:movieController animated:YES completion:nil];
    [movieController.moviePlayer play];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

