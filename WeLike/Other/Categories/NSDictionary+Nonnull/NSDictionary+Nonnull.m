//
//  NSDictionary+Nonnull.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "NSDictionary+Nonnull.h"

@implementation NSDictionary (Nonnull)

- (instancetype)nonnullDictionary
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    for (NSString *key in self.allKeys) {
        id obj = [self objectForKey:key];
        if (obj != [NSNull null]) {
            if (([obj isKindOfClass:[NSString class]] && [obj isEqualToString:@"null"])) {
                continue;
            }
            [newDict setValue:obj forKey:key];
        }
    }
    return newDict;
}

@end

