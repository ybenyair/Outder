//
//  TemplateCoreData.h
//  Outder
//
//  Created by Yossi on 6/25/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateCoreData : NSObject

+ (NSArray *) getPromotedTemplates:(NSManagedObjectContext *)context;
+ (void)fillTemplates:(NSManagedObjectContext *)context data:(NSDictionary *)json;
+ (void)clearDB:(NSManagedObjectContext *)context;

@end
