//
//  ALAsset+Copy.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/18/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "ALAsset+Copy.h"

@implementation ALAsset (Copy)

- (BOOL)syncCopyToFileWithPath:(NSString *)filePath
{
    ALAssetRepresentation *representation = [self defaultRepresentation];
    
    NSOutputStream *mediaStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [mediaStream open];
    
    NSUInteger bufferSize = 65536;
    NSUInteger read = 0, offset = 0, written = 0;
    uint8_t *buff = (uint8_t *)malloc(sizeof(uint8_t)*bufferSize);
    NSError *err = nil;
    
    do {
        read = [representation getBytes:buff fromOffset:offset length:bufferSize error:&err];
        written = [mediaStream write:buff maxLength:read];
        offset += read;
        if (err != nil) {
            NSLog(@"ERROR!!:%@",err);
            [mediaStream close];
            free(buff);
            return NO;
        }
        if (read != written) {
            NSLog(@"ERROR!!%@ Couldn't prepare data for upload!", mediaStream.streamError);
            [mediaStream close];
            free(buff);
            return NO;
        }
    } while (read != 0);
    
    free(buff);
    [mediaStream close];
    
    return YES;
}

- (void)asyncCopyToFileWithPath:(NSString *)filePath completion:(void(^)(BOOL success))completion
{
    dispatch_async(dispatch_queue_create("copy", DISPATCH_QUEUE_SERIAL), ^{
        BOOL success = [self syncCopyToFileWithPath:filePath];
        if (completion) {
            completion(success);
        }
    });
}

@end
