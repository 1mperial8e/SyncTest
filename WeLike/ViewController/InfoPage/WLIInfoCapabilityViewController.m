//
//  WLIInfoCapabilityViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 25/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIInfoCapabilityViewController.h"

@interface WLIInfoCapabilityViewController ()

@end

@implementation WLIInfoCapabilityViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"CAPABILITY";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    scrollView.contentSize = CGSizeMake(320, 630);
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
