//
//  NewsDetail+CoreDataClass.h
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewsDetail : NSManagedObject

-(void)deserialize:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "NewsDetail+CoreDataProperties.h"
