//
//  WLICategorySelectTableViewCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface WLICategorySelectTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *marketBtn;
@property (strong, nonatomic) IBOutlet UIButton *capabilityBtn;
@property (strong, nonatomic) IBOutlet UIButton *customerBtn;
@property (strong, nonatomic) IBOutlet UIButton *peopleBtn;
@property (strong, nonatomic) NSMutableDictionary *catDict;

@end
