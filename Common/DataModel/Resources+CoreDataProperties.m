//
//  Resources+CoreDataProperties.m
//  
//
//  Created by Nuno Silva on 10/04/2017.
//
//

#import "Resources+CoreDataProperties.h"

@implementation Resources (CoreDataProperties)

+ (NSFetchRequest<Resources *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Resources"];
}

@dynamic htmlHeader;
@dynamic htmlFooter;

@end
