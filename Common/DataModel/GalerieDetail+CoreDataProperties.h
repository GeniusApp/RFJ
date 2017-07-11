//
//  GalerieDetail+CoreDataProperties.h
//  
//
//  Created by Goncalo Girao on 06/06/2017.
//
//

#import "GalerieDetail+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface GalerieDetail (CoreDataProperties)

+ (NSFetchRequest<GalerieDetail *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSArray *contentGallery;
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


@end

NS_ASSUME_NONNULL_END
