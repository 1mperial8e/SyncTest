//
//  WLICategorySelectTableViewCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLICategorySelectTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *marketBtn;
@property (strong, nonatomic) IBOutlet UIButton *capabilityBtn;
@property (strong, nonatomic) IBOutlet UIButton *customerBtn;
@property (strong, nonatomic) IBOutlet UIButton *peopleBtn;
@property (strong, nonatomic) NSMutableDictionary *catDict;


- (IBAction)switchMAValueChanged:(id)sender;
- (IBAction)switchCAValueChanged:(id)sender;
- (IBAction)switchCUValueChanged:(id)sender;
- (IBAction)switchPEValueChanged:(id)sender;

@end
