//
//  WLICountryFilterTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface WLICountryFilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (copy, nonatomic) void (^countrySelectedHandler)(NSInteger);

+ (NSString *)ID;
+ (UINib *)nib;

@end
