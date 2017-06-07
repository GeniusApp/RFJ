//
//  GalerieDetail+CoreDataClass.m
//  rfj
//
//  Created by Goncalo Girao on 06/06/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GalerieDetail+CoreDataClass.h"
#import "Validation.h"

@implementation GalerieDetail

-(void)deserialize:(NSDictionary *)dictionary {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    if(VALID_NOTEMPTY(dictionary, NSDictionary)) {
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Content"], NSString)) {
            self.content = [dictionary objectForKey:@"Content"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"ContentGallery"], NSArray)) {
            self.content = [dictionary objectForKey:@"ContentGallery"];
        }

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
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"Link"], NSString)) {
            self.link = [dictionary objectForKey:@"Link"];
        }
        
        if(VALID_NOTEMPTY([dictionary objectForKey:@"NavigationId"], NSNumber)) {
            self.navigationId = [[dictionary objectForKey:@"NavigationId"] integerValue];
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
    }
}

@end
