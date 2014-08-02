//
//  SubTemplate.h
//  Outder
//
//  Created by Yossi on 8/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed, Instruction, Template, UserText;

@interface SubTemplate : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * makeOneDisable;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSSet *feeds;
@property (nonatomic, retain) NSSet *instructions;
@property (nonatomic, retain) Template *template;
@property (nonatomic, retain) NSSet *userTexts;
@end

@interface SubTemplate (CoreDataGeneratedAccessors)

- (void)addFeedsObject:(Feed *)value;
- (void)removeFeedsObject:(Feed *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

- (void)addInstructionsObject:(Instruction *)value;
- (void)removeInstructionsObject:(Instruction *)value;
- (void)addInstructions:(NSSet *)values;
- (void)removeInstructions:(NSSet *)values;

- (void)addUserTextsObject:(UserText *)value;
- (void)removeUserTextsObject:(UserText *)value;
- (void)addUserTexts:(NSSet *)values;
- (void)removeUserTexts:(NSSet *)values;

@end
