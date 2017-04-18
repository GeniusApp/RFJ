//
//  NewsDetail+CoreDataProperties.h
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//

#import "NewsDetail+CoreDataClass.h"
@class NewsPhoto;

NS_ASSUME_NONNULL_BEGIN

@interface NewsDetail (CoreDataProperties)

+ (NSFetchRequest<NewsDetail *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSDate *displayDateStart;
@property (nullable, nonatomic, copy) NSDate *displayDateStop;
@property (nonatomic) int64_t id;
@property (nullable, nonatomic, copy) NSString *image;
@property (nullable, nonatomic, copy) NSString *link;
@property (nonatomic) int64_t navigationId;
@property (nullable, nonatomic, copy) NSString *retina1;
@property (nullable, nonatomic, copy) NSString *retina2;
@property (nullable, nonatomic, copy) NSString *retina3;
@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int16_t type;
@property (nullable, nonatomic, copy) NSDate *updateDate;
@property (nullable, nonatomic, retain) NSSet<NewsPhoto *> *photos;

@end

@interface NewsDetail (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(NewsPhoto *)value;
- (void)removePhotosObject:(NewsPhoto *)value;
- (void)addPhotos:(NSSet<NewsPhoto *> *)values;
- (void)removePhotos:(NSSet<NewsPhoto *> *)values;

@end

NS_ASSUME_NONNULL_END
