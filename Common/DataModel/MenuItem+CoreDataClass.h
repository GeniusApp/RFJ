//
//  MenuItem+CoreDataClass.h
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuItem : NSManagedObject
+(MenuItem *)fromDictionary:(NSDictionary *)dictionary;
+(MenuItem *)fromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)localContext;
+(NSArray<MenuItem *> *)sortedMenuItems;
-(void)deserialize:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "MenuItem+CoreDataProperties.h"
