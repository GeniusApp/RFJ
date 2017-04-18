//
//  NewsDetail+CoreDataProperties.m
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//

#import "NewsDetail+CoreDataProperties.h"

@implementation NewsDetail (CoreDataProperties)

+ (NSFetchRequest<NewsDetail *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NewsDetail"];
}

@dynamic content;
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
@dynamic photos;

@end
