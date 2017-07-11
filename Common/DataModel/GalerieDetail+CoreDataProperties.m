//
//  GalerieDetail+CoreDataProperties.m
//  
//
//  Created by Goncalo Girao on 06/06/2017.
//
//

#import "GalerieDetail+CoreDataProperties.h"

@implementation GalerieDetail (CoreDataProperties)

+ (NSFetchRequest<GalerieDetail *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GalerieDetail"];
}

@dynamic content;
@dynamic contentGallery;
@dynamic createDate;
@dynamic displayDateStart;
@dynamic displayDateStop;
@dynamic id;
@dynamic image;
@dynamic link;
@dynamic navigationId;
@dynamic retina1;
@dynamic retina2;
@dynamic retina3;
@dynamic title;
@dynamic type;
@dynamic updateDate;


@end
