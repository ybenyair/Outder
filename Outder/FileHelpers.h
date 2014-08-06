//
//  FileHelpers.h
//  Outder
//
//  Created by Yossi on 8/6/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHelpers : NSObject

+ (void) deleteFiles: (NSSet *)instructions;
+ (void) deleteVideoFiles: (NSMutableArray *)files;
+ (void) deleteImageFiles: (NSMutableArray *)files;


@end
