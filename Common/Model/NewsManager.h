//
//  NewsManager.h
//  rfj
//
//  Created by Nuno Silva on 28/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsDetail+CoreDataProperties.h"
#import "GalerieDetail+CoreDataProperties.h"
#import "NewsItem+CoreDataProperties.h"
#import "GalerieItem+CoreDataProperties.h"
#import "NSObject+Singleton.h"
#import "Validation.h"

@class MenuItem;

@interface NewsManager : NSObject
-(void)fetchNewsAtPage:(NSInteger)page objectType:(NSInteger)objectType categoryId:(NSInteger)categoryId withSuccessBlock:(void(^)(NSArray<NewsItem *> *items))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock;

-(void)fetchImagesAtPage:(NSInteger)page objectType:(NSInteger)objectType categoryId:(NSInteger)categoryId withSuccessBlock:(void(^)(NSArray<GalerieItem *> *photos))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock;

-(void)fetchNewsAtPage:(NSInteger)page objectType:(NSInteger)objectType withSuccessBlock:(void(^)(NSArray<NewsItem *> *items))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock;

-(void)fetchNewsDetailForNews:(NSInteger)newsID successBlock:(void(^)(NewsDetail *newsDetail))successBlock andFailureBlock:(void(^)(NSError *error, NewsDetail *oldNewsDetail))failureBlock;

-(void)fetchImagesAtPage:(NSInteger)page objectType:(NSInteger)objectType withSuccessBlock:(void(^)(NSArray<GalerieItem *> *photos))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock;

-(void)fetchGalerieDetailForNews:(NSInteger)newsID successBlock:(void(^)(GalerieDetail *galerieDetail))successBlock andFailureBlock:(void(^)(NSError *error, GalerieDetail *oldGalerieDetail))failureBlock;

@end
