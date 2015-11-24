//
//  VideoConversionService.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/17/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "VideoConversionService.h"
#import <AVFoundation/AVFoundation.h>

static NSInteger const MaxCurrentThreadsCount = 3;

@interface VideoConversionService ()

@property (strong, nonatomic) NSMutableArray *filesToConvert;
@property (strong, nonatomic) NSMutableArray *canceledFiles;
@property (assign, nonatomic) NSInteger currentThreads;

@property (assign, nonatomic) BOOL shouldStopAllConversions;

@end

@implementation VideoConversionService

#pragma mark - Singleton

+ (instancetype)sharedService
{
    static id sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    return sharedService;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

#pragma mark - Private

- (void)setupDefaults
{
    self.filesToConvert = [NSMutableArray array];
    self.canceledFiles = [NSMutableArray array];
    self.currentThreads = 0;
    self.shouldStopAllConversions = NO;
}

- (void)startNextOperation
{
    self.currentThreads--;
    NSDictionary *dict = [self.filesToConvert firstObject];
    if (dict) {
        [self.filesToConvert removeObject:dict];
        [self convertVideoToLowQuailtyWithInputURL:dict[@"inputUrl"] outputURL:dict[@"outputUrl"] fileId:dict[@"fileId"] withCompletion:dict[@"completion"]];
    } else {
        self.shouldStopAllConversions = NO;
        [self.canceledFiles removeAllObjects];
    }
}

- (BOOL)shouldCancelConversion:(NSString *)fileId
{
    if (self.shouldStopAllConversions) {
        return YES;
    }
    return [self.canceledFiles containsObject:fileId];
}

#pragma mark - Video converting

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL *)inputURL
                                   outputURL:(NSURL *)outputURL
                                      fileId:(NSString *)fileId
                              withCompletion:(void(^)(NSString *path))completion
{
    NSParameterAssert(inputURL);
    NSParameterAssert(outputURL);
    NSParameterAssert(fileId);
    NSParameterAssert(completion);
    if (self.currentThreads >= MaxCurrentThreadsCount) {
        NSDictionary *dict = @{@"inputUrl" : inputURL,
                               @"outputUrl" : outputURL,
                               @"fileId" : fileId,
                               @"completion" : completion};
        [self.filesToConvert addObject:dict];
        return;
    }
    self.currentThreads++;
    NSLog(@"start converting file %@", outputURL.path);

    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputURL.path error:nil];
    }
    
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    if (!videoTrack && completion) {
        completion(@"");
        [self startNextOperation];
        return;
    }
    
    NSParameterAssert(videoTrack);

    CGSize videoSize = videoTrack.naturalSize;
    if (videoSize.width > 1280) {
        CGFloat coef = 1280 / videoSize.width;
        videoSize = CGSizeMake(1280, videoSize.height * coef);
    }
    NSDictionary *videoWriterCompressionSettings = @{AVVideoAverageBitRateKey : [NSNumber numberWithInt:1200000]};
    NSDictionary *videoWriterSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                          AVVideoCompressionPropertiesKey : videoWriterCompressionSettings,
                                          AVVideoWidthKey : [NSNumber numberWithFloat:videoSize.width],
                                          AVVideoHeightKey : [NSNumber numberWithFloat:videoSize.height]};
    
    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoWriterSettings];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    videoWriterInput.transform = videoTrack.preferredTransform;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
    NSParameterAssert(videoWriter);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    
    [videoWriter addInput:videoWriterInput];
    
    NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
    
    NSParameterAssert(videoReader);
    NSParameterAssert([videoReader canAddOutput:videoReaderOutput]);
    
    [videoReader addOutput:videoReaderOutput];
    
    AVAssetWriterInput *audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
    audioWriterInput.expectsMediaDataInRealTime = NO;
    
    NSParameterAssert([videoWriter canAddInput:audioWriterInput]);
    [videoWriter addInput:audioWriterInput];
    
    AVAssetTrack *audioTrack = [videoAsset tracksWithMediaType:AVMediaTypeAudio].count > 0 ? [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] : nil;
    
    AVAssetReader *audioReader;
    AVAssetReaderOutput *audioReaderOutput;
    if (audioTrack) {
        audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
        [audioReader addOutput:audioReaderOutput];
    }
    
    [videoWriter startWriting];
    [videoReader startReading];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    if (videoReader.status == AVAssetReaderStatusFailed) {
        [videoWriter finishWritingWithCompletionHandler:^{
            if (completion) {
                completion(@"");
            }
            NSLog(@"Failed converting file %@", videoWriter.outputURL.path);
        }];
        [self startNextOperation];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t videoQueue = dispatch_queue_create([[NSUUID UUID].UUIDString UTF8String], DISPATCH_QUEUE_SERIAL);
    [videoWriterInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
        while ([videoWriterInput isReadyForMoreMediaData]) {
            @autoreleasepool {
                if ([weakSelf shouldCancelConversion:fileId]) {
                    [weakSelf.canceledFiles removeObject:fileId];
                    [videoWriterInput markAsFinished];
                    [videoWriter finishWritingWithCompletionHandler:^{
                        if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
                            [[NSFileManager defaultManager] removeItemAtPath:outputURL.path error:nil];
                        }
                    }];
                    return;
                }
                CMSampleBufferRef sampleBuffer;
                if ([videoReader status] == AVAssetReaderStatusReading) {
                    sampleBuffer = [videoReaderOutput copyNextSampleBuffer];
                    if (sampleBuffer) {
                        BOOL appended = [videoWriterInput appendSampleBuffer:sampleBuffer];
                        if (!appended) {
                            NSLog(@"Error add video buffer %@", videoWriter.error);
                        }
                        CFRelease(sampleBuffer);
                    }
                } else {
                    [videoWriterInput markAsFinished];
                    if ([videoReader status] == AVAssetReaderStatusCompleted && audioReader) {
                        if ([audioReader status] == AVAssetReaderStatusReading || [audioReader status] == AVAssetReaderStatusCompleted) {
                            // reading already runs
                        } else {
                            [audioReader startReading];
                            [videoWriter startSessionAtSourceTime:kCMTimeZero];
                            
                            dispatch_queue_t audioQueue = dispatch_queue_create([[NSUUID UUID].UUIDString UTF8String], DISPATCH_QUEUE_SERIAL);
                            [audioWriterInput requestMediaDataWhenReadyOnQueue:audioQueue usingBlock:^{
                                while (audioWriterInput.readyForMoreMediaData) {
                                    if ([weakSelf shouldCancelConversion:fileId]) {
                                        [weakSelf.canceledFiles removeObject:fileId];
                                        [audioWriterInput markAsFinished];
                                        [videoWriter finishWritingWithCompletionHandler:^{
                                            if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
                                                [[NSFileManager defaultManager] removeItemAtPath:outputURL.path error:nil];
                                            }
                                        }];
                                        return;
                                    }
                                    CMSampleBufferRef audioBuffer;
                                    if ([audioReader status] == AVAssetReaderStatusReading) {
                                        audioBuffer = [audioReaderOutput copyNextSampleBuffer];
                                        if (audioBuffer) {
                                            BOOL appended = [audioWriterInput appendSampleBuffer:audioBuffer];
                                            if (!appended) {
                                                NSLog(@"Error add audio %@", videoWriter.error);
                                            }
                                            CFRelease(audioBuffer);
                                        }
                                    } else {
                                        [audioWriterInput markAsFinished];
                                        if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                            [videoWriter finishWritingWithCompletionHandler:^() {
                                                NSString *moviePath = [videoWriter.outputURL path];
                                                if (videoWriter.error) {
                                                    moviePath = @"";
                                                }
                                                NSLog(@"finished converting file %@", videoWriter.outputURL.path);
                                                [weakSelf startNextOperation];
                                                if (completion) {
                                                    completion(moviePath);
                                                }
                                            }];
                                        }
                                        break;
                                    }
                                }
                            }];
                        }
                        break;
                    } else if ([videoReader status] == AVAssetReaderStatusCompleted) {
                        [videoWriter finishWritingWithCompletionHandler:^() {
                            NSString *moviePath = [videoWriter.outputURL path];
                            if (videoWriter.error) {
                                moviePath = @"";
                            }
                            NSLog(@"finished converting file %@", videoWriter.outputURL.path);
                            [weakSelf startNextOperation];
                            if (completion) {
                                completion(moviePath);
                            }
                        }];
                        break;
                    } else if ([videoReader status] == AVAssetReaderStatusCompleted) {
                        [videoWriter finishWritingWithCompletionHandler:^() {
                            NSString *moviePath = [videoWriter.outputURL path];
                            if (videoWriter.error) {
                                moviePath = @"";
                            }
                            NSLog(@"finished converting file %@", videoWriter.outputURL.path);
                            [weakSelf startNextOperation];
                            if (completion) {
                                completion(moviePath);
                            }
                        }];
                        break;
                    } else if (videoReader.status == AVAssetReaderStatusFailed) {
                        if (![[NSFileManager defaultManager] fileExistsAtPath:inputURL.path]) {
                            NSLog(@"File was deleted!!!!");
                        }
                        [videoWriter finishWritingWithCompletionHandler:^{
                            NSLog(@"Failed converting file %@", videoWriter.outputURL.path);
                            NSLog(@"%@", videoReader.error);
                            [weakSelf startNextOperation];
                            if (completion) {
                                completion(@"");
                            }
                        }];
                        break;
                    }
                }
            }
        }
    }];
}

- (void)cancelConvertFile:(id)loadInfo
{
    if (self.currentThreads) {
        // if some conversion processes running
        [self.canceledFiles addObject:loadInfo];
    }
}

- (void)stopAllConversions
{
    if (self.currentThreads || self.filesToConvert.count) {
        self.shouldStopAllConversions = YES;
    }
}

@end
