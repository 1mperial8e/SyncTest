//
//  VideoConversionService.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/17/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface VideoConversionService : NSObject

+ (instancetype)sharedService;

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL *)inputURL
                                   outputURL:(NSURL *)outputURL
                                      fileId:(NSString *)fileId
                              withCompletion:(void(^)(NSString *path))completion;
- (void)cancelConvertFile:(NSString *)fileId;
- (void)stopAllConversions;

@end
