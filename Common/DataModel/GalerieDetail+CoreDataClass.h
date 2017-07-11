//
//  GalerieDetail+CoreDataClass.h
//  rfj
//
//  Created by Goncalo Girao on 06/06/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalerieDetail : NSManagedObject

-(void)deserialize:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "GalerieDetail+CoreDataProperties.h"
