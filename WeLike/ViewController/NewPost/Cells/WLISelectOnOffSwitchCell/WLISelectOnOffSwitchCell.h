//
//  WLISelectOnOffSwitchCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 26/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//
#import "WLIBaseTableViewCell.h"

@interface WLISelectOnOffSwitchCell : WLIBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *attribName;
@property (weak, nonatomic) IBOutlet UISwitch *attribSwitch;
@property (strong, nonatomic) NSMutableDictionary *cellContent;

@end
