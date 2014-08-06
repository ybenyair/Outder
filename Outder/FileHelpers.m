//
//  FileHelpers.m
//  Outder
//
//  Created by Yossi on 8/6/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FileHelpers.h"
#import "Instruction.h"
#import "SubTemplate.h"
#import "CoreData.h"

@implementation FileHelpers


+ (void) deleteFiles: (NSSet *)instructions
{
    NSMutableArray *imageFiles = [[NSMutableArray alloc] init];
    NSMutableArray *videoFiles = [[NSMutableArray alloc] init];
    
    for (id dataElement in instructions) {
        Instruction *inst = (Instruction *)dataElement;
        if ([inst.fixed boolValue] == NO)
        {
            if (inst.videoURL) {
                [videoFiles addObject:inst.videoURL];
                inst.videoURL = nil;
            }
            
            if (inst.imageURL) {
                [imageFiles addObject:inst.imageURL];
                inst.imageURL = nil;
            }
        }
    }
    
    [CoreData saveDB];
    
    [FileHelpers deleteVideoFiles:videoFiles];
    [FileHelpers deleteImageFiles:imageFiles];
}

+ (void) deleteVideoFiles: (NSMutableArray *)files
{
    NSLog(@"Video files to delete: %ld", (long)[files count]);
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.outder.deletevideofiles",NULL);
    dispatch_async(myQueue, ^{
        
        for (id dataElement in files) {
            NSString *file = (NSString *)dataElement;
            NSError* error = nil;
            NSURL *url = [NSURL URLWithString:file];
            NSLog(@"Delete video file %@", url);
            [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
        
        NSLog(@"Done removinging video files");
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        
    });
}

+ (void) deleteImageFiles: (NSMutableArray *)files
{
    NSLog(@"Image files to delete: %ld", (long)[files count]);
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.outder.deleteimagefiles",NULL);
    dispatch_async(myQueue, ^{
        
        for (id dataElement in files) {
            NSString *file = (NSString *)dataElement;
            NSError* error = nil;
            NSLog(@"Delete image file %@", file);
            [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
            
            if (error) {
                NSLog(@"%@", error);
            }
        }
        
        NSLog(@"Done removinging images files");
        
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        
    });
}

@end
