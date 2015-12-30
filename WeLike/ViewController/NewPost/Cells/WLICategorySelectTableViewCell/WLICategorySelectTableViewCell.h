//
//  WLICategorySelectTableViewCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface WLICategorySelectTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *marketBtn;
@property (weak, nonatomic) IBOutlet UIButton *capabilityBtn;
@property (weak, nonatomic) IBOutlet UIButton *customerBtn;
@property (weak, nonatomic) IBOutlet UIButton *peopleBtn;
@property (strong, nonatomic) NSMutableDictionary *catDict;

@end
