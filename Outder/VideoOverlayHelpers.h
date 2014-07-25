//
//  VideoOverlayHelpers.h
//  Outder
//
//  Created by Yossi on 7/25/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPlayerViewController.h"
#import "Instruction.h"

@interface VideoOverlayHelpers : NSObject

+ (VideoOverlay *) getVideoOverlay: (Instruction *)inst;

@end
