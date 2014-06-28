//
//  SubTemplate.h
//  Outder
//
//  Created by Yossi on 6/28/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Instruction, Template;

@interface SubTemplate : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *instructions;
@property (nonatomic, retain) Template *template;
@end

@interface SubTemplate (CoreDataGeneratedAccessors)

- (void)addInstructionsObject:(Instruction *)value;
- (void)removeInstructionsObject:(Instruction *)value;
- (void)addInstructions:(NSSet *)values;
- (void)removeInstructions:(NSSet *)values;

@end
