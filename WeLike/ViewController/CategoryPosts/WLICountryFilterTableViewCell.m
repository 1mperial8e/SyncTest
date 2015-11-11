//
//  WLICountryFilterTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLICountryFilterTableViewCell.h"

@implementation WLICountryFilterTableViewCell

#pragma mark - Static

+ (NSString *)ID
{
    return NSStringFromClass(self.class);
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:self.ID bundle:nil];
}

#pragma mark - Actions

- (IBAction)selectedCategoryChanged:(UISegmentedControl *)sender
{
    if (self.countrySelectedHandler) {
        self.countrySelectedHandler(sender.selectedSegmentIndex);
    }
}

@end
