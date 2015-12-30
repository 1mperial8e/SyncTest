//
//  WLISelectOnOffSwitchCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 26/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface WLISelectOnOffSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *attribName;
@property (weak, nonatomic) IBOutlet UISwitch *attribSwitch;
@property (strong, nonatomic) NSMutableDictionary *cellContent;

@end
