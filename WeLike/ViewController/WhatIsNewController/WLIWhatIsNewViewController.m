//
//  WLIWhatIsNewViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 12/16/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIWhatIsNewViewController.h"

@interface WLIWhatIsNewViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end

@implementation WLIWhatIsNewViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.separatorHeightConstraint.constant = 0.5;
	self.title = @"What is new";
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:NewFeaturesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.textView.contentOffset = CGPointZero;
}

#pragma mark - Actions

- (void)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
