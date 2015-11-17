//
//  WLICountryFilterTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"

@interface WLICountryFilterTableViewCell : WLIBaseTableViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (copy, nonatomic) void (^countrySelectedHandler)(NSInteger);

@end
