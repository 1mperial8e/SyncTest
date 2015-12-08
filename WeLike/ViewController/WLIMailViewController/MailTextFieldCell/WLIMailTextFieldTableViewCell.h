//
//  WLIMailTextFieldTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 08.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"

@interface WLIMailTextFieldTableViewCell : WLIBaseTableViewCell
@property (weak,nonatomic) IBOutlet UITextField * textField;
@property (weak,nonatomic) IBOutlet UILabel * labelFakePlaceholder;
@end
