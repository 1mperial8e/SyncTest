//
//  WLITimelineSettingsTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"

@protocol WLITimelineSettingsTableViewCellDelegate <NSObject>

@optional

- (void)stateSwitched:(BOOL)state forCountryIndex:(NSInteger)index;

@end

@interface WLITimelineSettingsTableViewCell : WLIBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UISwitch *countryStateSwitch;
@property (weak, nonatomic) id<WLITimelineSettingsTableViewCellDelegate> delegate;

@end
