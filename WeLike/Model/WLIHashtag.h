//
//  WLIHashtag.h
//  MyDrive
//
//  Created by Geir Eliassen on 08/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIObject.h"

@interface WLIHashtag : WLIObject

@property (nonatomic, strong) NSString *tagname;
@property (nonatomic) int tagcount;


- (id)initWithDictionary:(NSDictionary*)userWithInfo;

@end
