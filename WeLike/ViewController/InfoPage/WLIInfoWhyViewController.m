//
//  WLIInfoWhyViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 25/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIInfoWhyViewController.h"

@interface WLIInfoWhyViewController ()

@end

@implementation WLIInfoWhyViewController

#pragma mark - Object lifecycle

//-(id)initWithCoder:(NSCoder*)coder
//{
//    self = [super init];
//    if (self) {
//        // Custom initialization
//        self.title = @"Why 20 % by 2020?";
//    }
//    return self;
//}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Why 20 % by 2020?";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    scrollView.contentSize = CGSizeMake(320, 1116);
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, CGRectGetMaxY(insetView.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
