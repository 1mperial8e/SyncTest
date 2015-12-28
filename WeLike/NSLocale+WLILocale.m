//
//  NSLocale+WLILocale.m
//  MyDrive
//
//  Created by Roman R on 28.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#if TARGET_IPHONE_SIMULATOR

#import <objc/runtime.h>
#import "NSLocale+WLILocale.h"

@implementation NSLocale (WLILocale)

+ (void)load
{
	Method originalMethod = class_getClassMethod(self, @selector(currentLocale));
	Method swizzledMethod = class_getClassMethod(self, @selector(swizzled_currentLocale));
	method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (NSLocale*)swizzled_currentLocale
{
	return [NSLocale localeWithLocaleIdentifier:LOCALE_IDENTIFIER];
}

@end

#endif
