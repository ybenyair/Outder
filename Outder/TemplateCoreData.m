//
//  TemplateCoreData.m
//  Outder
//
//  Created by Yossi on 6/25/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "TemplateCoreData.h"
#import "Template.h"

@implementation TemplateCoreData

+ (void)saveDB:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (void)clearDB:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Template"];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // handle error
    } else {
        for (NSManagedObject *object in objects) {
            [context deleteObject:object];
        }
        [TemplateCoreData saveDB:context];
    }
}

+ (Template *)getTemplate:(NSManagedObjectContext *)context templateID:(NSString *)templateID
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Template"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", templateID];
    NSError *error;
    Template *template = nil;
    template = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !template) {
        // Create the initial userInfo entity in the DB
        template = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:context];
        template.id = 0;
        NSLog(@"New templateID = %@", templateID);
	} else {
        NSLog(@"Update templateID = %@", templateID);
    }
    
    return  template;
}

+ (void)fillTemplates:(NSManagedObjectContext *)context data:(NSDictionary *)json
{
    NSArray *dataArray = [json objectForKey:@"campaigns"];
    
    for (id dataElement in dataArray) {
        
        NSDictionary *templateData = (NSDictionary *)dataElement;
        NSString *templateID = [templateData objectForKey:@"id"];
        //NSString *templateID = [NSString stringWithFormat:@"%d",index];
        
        Template *template = [TemplateCoreData getTemplate:context templateID:templateID];
        
        if (template.id == 0) {
            NSString *field = nil;
            // A new template
            template.imageURL = [templateData objectForKey:@"dashboardimagekey"];
            template.title = [templateData objectForKey:@"name"];
            field = [templateData objectForKey:@"order"];
            template.order = [NSNumber numberWithInt:[field intValue]];
            field = [templateData objectForKey:@"id"];
            template.id = [NSNumber numberWithInt:[field intValue]];
    
        }
    }
}

@end
