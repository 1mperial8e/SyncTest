//
//  WLICountrySettings.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface WLICountrySettings : NSObject

@property (strong, nonatomic, readonly) NSArray *countries;
@property (strong, nonatomic, readonly) NSMutableArray *countriesEnabledState;

+ (instancetype)sharedSettings;
- (void)setState:(BOOL)state forCountryIndex:(NSInteger)index;

- (NSInteger)getEnabledCountriesCount;
- (NSString *)getEnabledCountriesStringID;

@end
