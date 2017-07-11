//
//  GalerieItem+CoreDataProperties.m
//  rfj
//
//  Created by Gonçalo Girão on 02/06/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GalerieItem+CoreDataProperties.h"

@implementation GalerieItem (CoreDataProperties)

+ (NSFetchRequest<GalerieItem *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"GalerieItem"];
}

@dynamic createDate;
@dynamic displayDateStart;
@dynamic displayDateStop;
@dynamic id;
@dynamic image;
@dynamic navigationId;
@dynamic read;
@dynamic retina1;
@dynamic retina2;
@dynamic retina3;
@dynamic title;
@dynamic type;
@dynamic important;
@dynamic updateDate;


@end
