//
//  GalerieItem+CoreDataClass.h
//  rfj
//
//  Created by Gonçalo Girão on 02/06/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalerieItem : NSManagedObject

+(GalerieItem *)fromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)localContext;
-(void)deserialize:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "GalerieItem+CoreDataProperties.h"
