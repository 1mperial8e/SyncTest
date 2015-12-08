//
//  WLIMailViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 08.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMailViewController.h"
#import "WLIMailTextViewTableViewCell.h"
#import "WLIMailTextFieldTableViewCell.h"

@interface WLIMailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WLIMailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.tableView registerNib:WLIMailTextFieldTableViewCell.nib forCellReuseIdentifier:WLIMailTextFieldTableViewCell.ID];
	[self.tableView registerNib:WLIMailTextViewTableViewCell.nib forCellReuseIdentifier:WLIMailTextViewTableViewCell.ID];
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
	
	self.navigationItem.title = @"New Email";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendEmailAction:)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cacelAction:)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 2) {
		WLIMailTextViewTableViewCell *mailTextViewCell = [tableView dequeueReusableCellWithIdentifier:WLIMailTextViewTableViewCell.ID forIndexPath:indexPath];
		return mailTextViewCell;
	} else {
		WLIMailTextFieldTableViewCell *mailTextFieldCell = [tableView dequeueReusableCellWithIdentifier:WLIMailTextFieldTableViewCell.ID forIndexPath:indexPath];
		if (indexPath.row == 0) {
			mailTextFieldCell.textField.text = @"santander@santanderconsumer.no";
			mailTextFieldCell.labelFakePlaceholder.text = @"To:";
			mailTextFieldCell.userInteractionEnabled = NO;
		} else if (indexPath.row == 1) {			
			mailTextFieldCell.labelFakePlaceholder.text = @"Subject:";
			mailTextFieldCell.textField.textColor = [UIColor colorWithWhite:0.31 alpha:1.0];
		}
		return mailTextFieldCell;
	}
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 45.f;
	if (indexPath.row == 2) {
		height = CGRectGetHeight(self.tableView.frame) - 2 * height;
	}
	return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetHeight(tableView.frame), 0, 0);
    }
}

#pragma mark - Actions methods

- (void)cacelAction:(id)sender
{
	[self.tableView endEditing:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendEmailAction:(id)sender
{
	
}

@end
