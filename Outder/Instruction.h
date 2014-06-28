//
//  Instruction.h
//  Outder
//
//  Created by Yossi on 6/28/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubTemplate;

@interface Instruction : NSManagedObject

@property (nonatomic, retain) NSNumber * fixed;
@property (nonatomic, retain) NSString * usertexthint;
@property (nonatomic, retain) NSNumber * usertext;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * minlength;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) SubTemplate *subTemplate;

@end
