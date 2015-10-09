//
//  WLIHashtag.m
//  MyDrive
//
//  Created by Geir Eliassen on 08/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIHashtag.h"

@implementation WLIHashtag

- (id)initWithDictionary:(NSDictionary*)userWithInfo {
    
    self = [self init];
    if (self) {
        _tagname = [self stringFromDictionary:userWithInfo forKey:@"tag"];
        _tagcount = [self integerFromDictionary:userWithInfo forKey:@"tagcount"];
    }
    
    return self;
}


#pragma mark - NSCoding methods

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.tagname forKey:@"tag"];
    [encoder encodeInt:self.tagcount forKey:@"tagcount"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {
        self.tagname = [decoder decodeObjectForKey:@"tag"];
        self.tagcount = (int)[decoder decodeIntegerForKey:@"tagcount"];
    }
    return self;
}

@end
