//
//  MenuItem+CoreDataClass.m
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import "MenuItem+CoreDataClass.h"
#import "Validation.h"

@implementation MenuItem

+(MenuItem *)fromDictionary:(NSDictionary *)dictionary {
    MenuItem *item = [MenuItem MR_createEntity];
    
    [item deserialize:dictionary];
    
    return item;
}

+(MenuItem *)fromDictionary:(NSDictionary *)dictionary inContext:(nonnull NSManagedObjectContext *)localContext {
    MenuItem *item = [MenuItem MR_createEntityInContext:localContext];
    
    [item deserialize:dictionary];
    
    return item;
}

+(NSArray<MenuItem *> *)sortedMenuItems {
    NSArray<MenuItem *> *outItems = [MenuItem MR_findAll];
    
    outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MenuItem *a = obj1;
        MenuItem *b = obj2;
        
        return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
    }];
    
    return outItems;
}

-(void)deserialize:(NSDictionary *)dictionary {
    if(VALID_NOTEMPTY(dictionary, NSDictionary)) {
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Id"], NSNumber)) {
            self.id = [[dictionary objectForKey:@"Id"] integerValue];
        }

        if(VALID_NOTEMPTY([dictionary objectForKey:@"ParentId"], NSNumber)) {
            self.parentId = [[dictionary objectForKey:@"ParentId"] integerValue];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Name"], NSString)) {
            self.name = [dictionary objectForKey:@"Name"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Link"], NSString)) {
            self.link = [dictionary objectForKey:@"Link"];
        }
    }
}

@end
