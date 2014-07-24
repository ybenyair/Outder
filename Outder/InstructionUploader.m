//
//  UploadInstruction.m
//  Outder
//
//  Created by Yossi on 7/23/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "InstructionUploader.h"

@implementation InstructionUploader

- (void) setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:&attributesError];
    self.fileSize = (long)[fileAttributes fileSize];
}

- (void)setProgress:(float)progress
{
    NSLog(@"UPLOAD INSTRCUTION: progress = %f [%@]", progress, self.instruction.name);
}

- (void)requestFinished:(ASIS3Request *)req
{
    NSLog(@"UPLOAD INSTRCUTION: done [%@]", self.instruction.name);
}

- (void)requestFailed:(ASIS3Request *)req
{
    NSLog(@"UPLOAD INSTRCUTION: error [%@]", self.instruction.name);
    NSLog(@"UPLOAD INSTRCUTION: %@",[[req error] localizedDescription]);
}

@end

