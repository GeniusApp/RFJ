//
//  NewsPhoto+CoreDataProperties.h
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//  This file was automatically generated and should not be edited.
//

#import "NewsPhoto+CoreDataClass.h"

@class NewsDetail;

NS_ASSUME_NONNULL_BEGIN

@interface NewsPhoto (CoreDataProperties)

+ (NSFetchRequest<NewsPhoto *> *)fetchRequest;

@property (nonatomic) int64_t id;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *photoDescription;
@property (nullable, nonatomic, retain) NewsDetail *owner;

@end

NS_ASSUME_NONNULL_END
