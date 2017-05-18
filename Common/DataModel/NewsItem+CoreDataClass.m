//
//  NewsItem+CoreDataClass.m
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import "NewsItem+CoreDataClass.h"
#import "Validation.h"

@implementation NewsItem

+(NewsItem*)fromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)localContext {
    NewsItem *item = [NewsItem MR_createEntityInContext:localContext];
    
    if(VALID_NOTEMPTY(dictionary, NSDictionary)) {
        [item deserialize:dictionary];
    }
    
    return item;
}

-(void)deserialize:(NSDictionary *)dictionary {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    if(VALID_NOTEMPTY(dictionary, NSDictionary)) {
        if(VALID_NOTEMPTY([dictionary objectForKey:@"CreateDate"], NSString)) {
            self.createDate = [dateFormatter dateFromString:[dictionary objectForKey:@"CreateDate"]];
        }

        if(VALID_NOTEMPTY([dictionary objectForKey:@"DisplayDateStart"], NSString)) {
            self.displayDateStart = [dateFormatter dateFromString:[dictionary objectForKey:@"DisplayDateStart"]];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"DisplayDateStop"], NSString)) {
            self.displayDateStop = [dateFormatter dateFromString:[dictionary objectForKey:@"DisplayDateStop"]];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Id"], NSNumber)) {
            self.id = [[dictionary objectForKey:@"Id"] integerValue];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Image"], NSString)) {
            self.image = [dictionary objectForKey:@"Image"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"NavigationId"], NSNumber)) {
            self.navigationId = [[dictionary objectForKey:@"NavigationId"] intValue];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Retina1"], NSString)) {
            self.retina1 = [dictionary objectForKey:@"Retina1"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Retina2"], NSString)) {
            self.retina2 = [dictionary objectForKey:@"Retina2"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Retina3"], NSString)) {
            self.retina3 = [dictionary objectForKey:@"Retina3"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Title"], NSString)) {
            self.title = [dictionary objectForKey:@"Title"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Type"], NSNumber)) {
            self.type = [[dictionary objectForKey:@"Type"] integerValue];
        }

        if(VALID_NOTEMPTY([dictionary objectForKey:@"UpdateDate"], NSString)) {
            self.updateDate = [dateFormatter dateFromString:[dictionary objectForKey:@"UpdateDate"]];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Important"], NSNumber)) {
            self.important = [[dictionary objectForKey:@"Important"] integerValue];
        }
    }
}

@end
