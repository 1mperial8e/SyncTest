//
//  WLIInfoPageViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 16/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIInfoPageViewController.h"

@interface WLIInfoPageViewController ()

@end

@implementation WLIInfoPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelButtonTouchUpInside:(id)sender
{
    exit(0);
//    [[NSThread mainThread] exit];
}
-(IBAction)loginButtonTouchUpInside:(id)sender
{
    
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
