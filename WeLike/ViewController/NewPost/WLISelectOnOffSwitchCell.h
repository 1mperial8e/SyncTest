//
//  WLISelectOnOffSwitchCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 26/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLISelectOnOffSwitchCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *attribName;
@property (strong, nonatomic) IBOutlet UISwitch *attribSwitch;
@property (strong, nonatomic) NSMutableDictionary *cellContent;

- (IBAction)switchValueChanged:(id)sender;

@end