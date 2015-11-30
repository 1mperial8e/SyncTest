//
//  WLIInfoWhyViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 25/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIInfoWhyViewController.h"

@interface WLIInfoWhyViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet UIView *insetView;

@end

@implementation WLIInfoWhyViewController

#pragma mark - Object lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Why 20 % by 2020?";
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, CGRectGetMaxY(self.insetView.frame));
}

@end
