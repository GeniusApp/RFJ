//
//  Resources+CoreDataProperties.h
//  
//
//  Created by Nuno Silva on 10/04/2017.
//
//

#import "Resources+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Resources (CoreDataProperties)

+ (NSFetchRequest<Resources *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *htmlHeader;
@property (nullable, nonatomic, copy) NSString *htmlFooter;

@end

NS_ASSUME_NONNULL_END
