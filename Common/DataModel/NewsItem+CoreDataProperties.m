//
//  NewsItem+CoreDataProperties.m
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//

#import "NewsItem+CoreDataProperties.h"

@implementation NewsItem (CoreDataProperties)

+ (NSFetchRequest<NewsItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NewsItem"];
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
@dynamic updateDate;

@end
