//
//  TemplateCoreData.m
//  Outder
//
//  Created by Yossi on 6/25/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "TemplateCoreData.h"
#import "Template.h"
#import "SubTemplate.h"
#import "Instruction.h"
#import "UserText.h"
#import "AppDelegate.h"
#import "Tip.h"

@implementation TemplateCoreData

+ (void)saveDB
{
    AppDelegate *app = [AppDelegate getInstance];
    NSManagedObjectContext *context = app.managedObjectContext;
    if ([context hasChanges]) {
        NSLog(@"DB changed");
    }
    
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
        [TemplateCoreData saveDB];
    }
}

+ (Template *)getTemplate:(NSManagedObjectContext *)context withId:(NSInteger)templateID atAutoCreate:(BOOL)create
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Template"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %d", templateID];
    NSError *error;
    Template *template = nil;
    template = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !template && create) {
        // Create the initial userInfo entity in the DB
        template = [NSEntityDescription insertNewObjectForEntityForName:@"Template" inManagedObjectContext:context];
        template.id = 0;
        NSLog(@"New templateID = %ld", (long)templateID);
	} else {
        NSLog(@"Update templateID = %ld", (long)templateID);
    }
    
    return  template;
}

+ (Instruction *)getInstruction:(NSManagedObjectContext *)context withId:(NSNumber *)InstructionID
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Instruction"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", InstructionID];
    NSError *error;
    Instruction *instruction = nil;
    instruction = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !instruction) {
        // Create the initial userInfo entity in the DB
        instruction = [NSEntityDescription insertNewObjectForEntityForName:@"Instruction" inManagedObjectContext:context];
        instruction.id = 0;
        NSLog(@"New Instruction = %ld", (long)[InstructionID integerValue]);
	} else {
        NSLog(@"Update Instruction = %ld", (long)[InstructionID integerValue]);
    }
    
    return instruction;
}

+ (void)fillInstructions: (NSArray *)instructions inSubTemplate:(SubTemplate *)subTemplate atContext:(NSManagedObjectContext *)context
{
    Instruction *instruction = nil;
    for (id dataElement in instructions) {
        NSDictionary *instructionData = (NSDictionary *)dataElement;
        NSNumber *numID = [instructionData objectForKey:@"id"];
        NSInteger intID = [numID integerValue] + [subTemplate.id integerValue] * 10000;
        numID = [NSNumber numberWithInteger:intID];
        instruction = [TemplateCoreData getInstruction:context withId:numID];
        
        instruction.id = numID;
        instruction.hidden = [instructionData objectForKey:@"hidden"];
        instruction.fixed = [instructionData objectForKey:@"fixed"];
        
        if ([instruction.fixed boolValue] == YES) {
            instruction.imageURL = [instructionData objectForKey:@"image"];
            instruction.videoURL = [instructionData objectForKey:@"video_url"];
        }
        
        instruction.selfi = [instructionData objectForKey:@"selfi"];
        instruction.usertexthint = [instructionData objectForKey:@"usertexthint"];
        instruction.usertext = [instructionData objectForKey:@"usertext"];
        instruction.name = [instructionData objectForKey:@"name"];
        instruction.minlength = [instructionData objectForKey:@"minlength"];
        instruction.length = [instructionData objectForKey:@"length"];
        
        instruction.overlayImagePrefixURL = [instructionData objectForKey:@"overlay_prefix_url"];
        instruction.overlayImageFirstIndex = [instructionData objectForKey:@"overlay_first_index"];
        instruction.overlayTrackURL = [instructionData objectForKey:@"overlay_track"];
        
        [subTemplate addInstructionsObject:instruction];
    }
}

+ (UserText *)getUserText:(NSString *)hintText withID:(NSNumber *)hintID atContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserText"];
    request.predicate = [NSPredicate predicateWithFormat:@"textHint = %@ AND id = %@", hintText, hintID];
    NSError *error;
    UserText *obj = nil;
    obj = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !obj) {
        // Create the initial userInfo entity in the DB
        obj = [NSEntityDescription insertNewObjectForEntityForName:@"UserText" inManagedObjectContext:context];
        NSLog(@"New userText object for hint: %@ id: %@", hintText, hintID);
	} else {
        NSLog(@"Update userText object for hint: %@ id: %@", hintText, hintID);
    }

    return  obj;
}

+ (void)fillUserTexts: (NSArray *)userTexts inSubTemplate:(SubTemplate *)subTemplate atContext:(NSManagedObjectContext *)context
{    
    for (id dataElement in userTexts) {
        NSString *data = (NSString *)dataElement;
        UserText *obj = [TemplateCoreData getUserText:data withID:subTemplate.id atContext:context];
        obj.textHint = data;
        obj.id = subTemplate.id;
        [subTemplate addUserTextsObject:obj];
    }
}

+ (Tip *)allocTip:(NSManagedObjectContext *)context
{
    Tip *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Tip" inManagedObjectContext:context];
    return  obj;
}

+ (void) removeAllTips: (SubTemplate *)subTemplate atContext:(NSManagedObjectContext *)context
{
    for (Tip * object in subTemplate.tips) {
        NSLog(@"remove tip: %@", object.text);
        [context deleteObject:object];
    }
}

+ (void)fillTips: (NSArray *)tips inSubTemplate:(SubTemplate *)subTemplate atContext:(NSManagedObjectContext *)context
{
    [TemplateCoreData removeAllTips:subTemplate atContext:context];
    
    NSInteger index = 0;
    for (id dataElement in tips) {
        index++;
        NSString *data = (NSString *)dataElement;
        Tip *obj = [TemplateCoreData allocTip:context];
        obj.text = data;
        obj.id = [NSNumber numberWithInteger:index];
        [subTemplate addTipsObject:obj];
        NSLog(@"add tip: %@", obj.text);
    }
}

+ (SubTemplate *)getSubTemplate:(NSManagedObjectContext *)context withId:(NSNumber *)subTemplateID
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SubTemplate"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %ld", (long)[subTemplateID integerValue]];
    NSError *error;
    SubTemplate *subTemplate = nil;
    subTemplate = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !subTemplate) {
        // Create the initial userInfo entity in the DB
        subTemplate = [NSEntityDescription insertNewObjectForEntityForName:@"SubTemplate" inManagedObjectContext:context];
        subTemplate.id = 0;
        NSLog(@"New subTemplate = %ld", (long)[subTemplateID integerValue]);
	} else {
        NSLog(@"Update subTemplate = %ld", (long)[subTemplateID integerValue]);
    }
    
    return  subTemplate;
}

+ (void)fillSubTemplates: (NSArray *)subTemplates inTemplate:(Template *)template atContext:(NSManagedObjectContext *)context
{
    SubTemplate *subTemplate = nil;
    for (id dataElement in subTemplates) {
        NSDictionary *subTemplateData = (NSDictionary *)dataElement;
        NSNumber *numID = [subTemplateData objectForKey:@"id"];
        subTemplate = [TemplateCoreData getSubTemplate:context withId:numID];
        subTemplate.id = [subTemplateData objectForKey:@"id"];
        subTemplate.order = [subTemplateData objectForKey:@"order"];
        subTemplate.imageURL = [subTemplateData objectForKey:@"image"];
        subTemplate.videoURL = [subTemplateData objectForKey:@"video_url"];
        subTemplate.title = [subTemplateData objectForKey:@"title"];
        subTemplate.name = [subTemplateData objectForKey:@"name"];
        
        [template addSubTemplatesObject:subTemplate];
        
        NSArray *instructions = [subTemplateData objectForKey:@"instructions"];
        [TemplateCoreData fillInstructions:instructions inSubTemplate:subTemplate atContext:context];
        
        NSArray *userTexts = [subTemplateData objectForKey:@"user_texts"];
        [TemplateCoreData fillUserTexts:userTexts inSubTemplate:subTemplate atContext:context];

        NSArray *tips = [subTemplateData objectForKey:@"tips"];
        [TemplateCoreData fillTips:tips inSubTemplate:subTemplate atContext:context];

    }
}

+ (void)fillTemplates:(NSManagedObjectContext *)context data:(NSDictionary *)json
{
    NSArray *dataArray = [json objectForKey:@"data"];
    
    for (id dataElement in dataArray) {
        
        NSDictionary *templateData = (NSDictionary *)dataElement;
        NSString *templateID = [templateData objectForKey:@"id"];
        NSInteger numId = [templateID intValue];
        Template *template = [TemplateCoreData getTemplate:context withId:numId atAutoCreate:YES];
        
        template.id = [templateData objectForKey:@"id"];
        template.order = [templateData objectForKey:@"order"];
        template.imageURL = [templateData objectForKey:@"image"];
        template.title = [templateData objectForKey:@"title"];
        template.promoted = [templateData objectForKey:@"promoted"];
        NSArray *subTemplates = [templateData objectForKey:@"subtemplate"];
        [TemplateCoreData fillSubTemplates:subTemplates inTemplate:template atContext:context];
    }
}

+ (NSArray *) getPromotedTemplates:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Template"];
    request.predicate = [NSPredicate predicateWithFormat:@"promoted = 1"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setFetchBatchSize:10];
    
    NSError *error;
    NSArray *result = nil;
    result = [context executeFetchRequest:request error:&error];
    return  result;
}


+ (Template *) getTemplate: (NSManagedObjectContext *)context byId:(NSInteger)id
{
    Template *template = [TemplateCoreData getTemplate:context withId:id atAutoCreate:NO];
    return template;
}

@end
