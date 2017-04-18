//
//  MenuItem+CoreDataProperties.h
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//

#import "MenuItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MenuItem (CoreDataProperties)

+ (NSFetchRequest<MenuItem *> *)fetchRequest;

@property (nonatomic) int64_t id;
@property (nonatomic) int64_t parentId;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
