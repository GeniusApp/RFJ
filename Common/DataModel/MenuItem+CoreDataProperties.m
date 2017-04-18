//
//  MenuItem+CoreDataProperties.m
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//

#import "MenuItem+CoreDataProperties.h"

@implementation MenuItem (CoreDataProperties)

+ (NSFetchRequest<MenuItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MenuItem"];
}

@dynamic parentId;
@dynamic id;
@dynamic link;
@dynamic name;

@end
