//
//  WLISelectCountryTableViewCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLISelectCountryTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *allBtn;
@property (strong, nonatomic) IBOutlet UIButton *denmarkBtn;
@property (strong, nonatomic) IBOutlet UIButton *finlandBtn;
@property (strong, nonatomic) IBOutlet UIButton *norwayBtn;
@property (strong, nonatomic) IBOutlet UIButton *swedenBtn;
@property (strong, nonatomic) NSMutableDictionary *countryDict;


- (IBAction)switchAValueChanged:(id)sender;
- (IBAction)switchDValueChanged:(id)sender;
- (IBAction)switchFValueChanged:(id)sender;
- (IBAction)switchNValueChanged:(id)sender;
- (IBAction)switchSValueChanged:(id)sender;

@end
