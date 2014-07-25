//
//  VideoOverlayHelpers.m
//  Outder
//
//  Created by Yossi on 7/25/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "VideoOverlayHelpers.h"

@implementation VideoOverlayHelpers


+ (VideoOverlay *) getVideoOverlay: (Instruction *)inst
{
    VideoOverlay *object = nil;
    
    if (inst.overlayImagePrefixURL) {
        NSUInteger frameRate = 25;
        NSUInteger firstItem = [inst.overlayImageFirstIndex integerValue];
        NSUInteger lastItem =  firstItem + [inst.length integerValue] * frameRate;
        
        object = [[VideoOverlay alloc] init];
        object.overlayImagesURL = [[NSMutableArray alloc] init];
        
        NSUInteger currentItem = firstItem;
        while (currentItem < lastItem) {
            NSString *url = [NSString stringWithFormat:@"%@%05lu.png", inst.overlayImagePrefixURL,(unsigned long)currentItem];
            [object.overlayImagesURL addObject:url];
            currentItem += 5;
        }
        
        object.overlayPeriod = (1 / (CGFloat)frameRate) * 5;
    }
    
    if (inst.overlayTrackURL) {
        if (!object) {
            object = [[VideoOverlay alloc] init];
        }
        
        object.overlayTrack = inst.overlayTrackURL;
    }
    
    return object;
}

@end
