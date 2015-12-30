//
//  WLISelectCountryTableViewCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface WLISelectCountryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *allBtn;
@property (weak, nonatomic) IBOutlet UIButton *denmarkBtn;
@property (weak, nonatomic) IBOutlet UIButton *finlandBtn;
@property (weak, nonatomic) IBOutlet UIButton *norwayBtn;
@property (weak, nonatomic) IBOutlet UIButton *swedenBtn;
@property (strong, nonatomic) NSMutableDictionary *countryDict;

@end
