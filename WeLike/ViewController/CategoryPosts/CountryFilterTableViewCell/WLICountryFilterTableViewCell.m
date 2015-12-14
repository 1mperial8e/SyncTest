//
//  WLICountryFilterTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLICountryFilterTableViewCell.h"

@implementation WLICountryFilterTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.segmentControl.selectedSegmentIndex = 4;
}

#pragma mark - Actions

- (IBAction)selectedCategoryChanged:(UISegmentedControl *)sender
{
    if (self.countrySelectedHandler) {
        self.countrySelectedHandler(sender.selectedSegmentIndex + 1);
    }
}

@end
