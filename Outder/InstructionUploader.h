//
//  UploadInstruction.h
//  Outder
//
//  Created by Yossi on 7/23/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedUploader.h"
#import "ASIS3ObjectRequest.h"
#import "Instruction.h"

@interface InstructionUploader : ASIS3ObjectRequest

@property (nonatomic) NSUInteger fileSize;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) Instruction *instruction;
@property (nonatomic, strong) FeedUploader *feedUploader;

@end
