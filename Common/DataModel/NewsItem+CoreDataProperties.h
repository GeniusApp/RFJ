//
//  NewsItem+CoreDataProperties.h
//  
//
//  Created by Nuno Silva on 02/03/2017.
//
//

#import "NewsItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NewsItem (CoreDataProperties)

+ (NSFetchRequest<NewsItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSDate *displayDateStart;
@property (nullable, nonatomic, copy) NSDate *displayDateStop;
@property (nonatomic) int64_t id;
@property (nullable, nonatomic, copy) NSString *image;
@property (nonatomic) int64_t navigationId;
@property (nonatomic) BOOL read;
@property (nullable, nonatomic, copy) NSString *retina1;
@property (nullable, nonatomic, copy) NSString *retina2;
@property (nullable, nonatomic, copy) NSString *retina3;
@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int16_t type;
@property (nonatomic) int16_t important;
@property (nullable, nonatomic, copy) NSDate *updateDate;

@end

NS_ASSUME_NONNULL_END
