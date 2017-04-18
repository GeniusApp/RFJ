//
//  NewsPhoto+CoreDataProperties.m
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//  This file was automatically generated and should not be edited.
//

#import "NewsPhoto+CoreDataProperties.h"

@implementation NewsPhoto (CoreDataProperties)

+ (NSFetchRequest<NewsPhoto *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NewsPhoto"];
}

@dynamic id;
@dynamic link;
@dynamic name;
@dynamic photoDescription;
@dynamic owner;

@end
