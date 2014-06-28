//
//  Template.h
//  Outder
//
//  Created by Yossi on 6/28/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubTemplate;

@interface Template : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * promoted;
@property (nonatomic, retain) NSSet *subTemplates;
@end

@interface Template (CoreDataGeneratedAccessors)

- (void)addSubTemplatesObject:(SubTemplate *)value;
- (void)removeSubTemplatesObject:(SubTemplate *)value;
- (void)addSubTemplates:(NSSet *)values;
- (void)removeSubTemplates:(NSSet *)values;

@end
