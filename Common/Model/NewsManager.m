//
//  NewsManager.m
//  rfj
//
//  Created by Nuno Silva on 28/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <MagicalRecord/MagicalRecord.h>
#import "NewsManager.h"
#import "Constants.h"
#import "DataManager.h"
#import "MenuItem+CoreDataProperties.h"


@implementation NewsManager
-(void)fetchNewsAtPage:(NSInteger)page objectType:(NSInteger)objectType withSuccessBlock:(void(^)(NSArray<NewsItem *> *items))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];

    NSString *url = [NSString stringWithFormat:kURLLastNewsFormat,
                     [[NSNumber numberWithInt:[[DataManager singleton] isRFJ] ? kZoneIDRFJ : [[DataManager singleton] isRJB] ? kZoneIDRJB : kZoneIDRTN] stringValue], [[NSNumber numberWithInteger:objectType] stringValue], @"0", [[NSNumber numberWithInteger:page] stringValue], [[NSNumber numberWithInteger:-1] stringValue]];
    
    NSError *urlError = nil;
    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:&urlError];
    
    __block NSArray<NewsItem *> *outItems = [NewsItem MR_findAll];
    
    outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NewsItem *a = obj1;
        NewsItem *b = obj2;
        
        return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
    }];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock(error);
                }
            });
        }
        else if(VALID(responseObject, NSArray)) {
            NSArray *jsonItems = responseObject;
            
            NSMutableArray<NSNumber *> *itemIDs = [[NSMutableArray<NSNumber *> alloc] init];

            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
                
                for(NSDictionary *itemDictionary in jsonItems) {
                    if(VALID_NOTEMPTY(itemDictionary, NSDictionary)) {
                        NewsItem *item = nil;
                        
                        if(VALID_NOTEMPTY([itemDictionary objectForKey:@"Id"], NSNumber)) {
                            NSNumber *id = [itemDictionary objectForKey:@"Id"];
                            
                            item = [NewsItem MR_findFirstByAttribute:@"id" withValue:id inContext:localContext];
                        }
                        
                        if(!VALID(item, NewsItem)) {
                            item = [NewsItem fromDictionary:itemDictionary inContext:localContext];
                        }
                        
                        if(VALID(item, NewsItem)) {
                            [item deserialize:itemDictionary];
                            [items addObject:item];
                            [itemIDs addObject:@(item.id)];
                        }
                    }
                }
                
                outItems = items;
            }];
            
            NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
            
            for(NSNumber *itemID in itemIDs)
            {
                NewsItem *item = [NewsItem MR_findFirstByAttribute:@"id" withValue:itemID];
                
                if(VALID(item, NewsItem)) {
                    [items addObject:item];
                }
            }
            
            outItems = items;
            
            outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NewsItem *a = obj1;
                NewsItem *b = obj2;
                
                return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock) {
                    successBlock(outItems);
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil]);
                }
            });
        }
    }];
    
    [dataTask resume];
}

-(void)fetchImagesAtPage:(NSInteger)page objectType:(NSInteger)objectType withSuccessBlock:(void(^)(NSArray<GalerieItem *> *photos))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];
    
    NSString *url = [NSString stringWithFormat:kURLLastNewsFormat,
                     [[NSNumber numberWithInt:[[DataManager singleton] isRFJ] ? kZoneIDRFJ : [[DataManager singleton] isRJB] ? kZoneIDRJB : kZoneIDRTN] stringValue], [[NSNumber numberWithInteger:objectType] stringValue], @"1", [[NSNumber numberWithInteger:page] stringValue], [[NSNumber numberWithInteger:-1] stringValue]];
    
    NSError *urlError = nil;
    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:&urlError];
    
    __block NSArray<GalerieItem *> *outItems = [GalerieItem MR_findAll];
    
    outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GalerieItem *a = obj1;
        GalerieItem *b = obj2;
        
        return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
    }];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock(error);
                }
            });
        }
        else if(VALID(responseObject, NSArray)) {
            NSArray *jsonItems = responseObject;
            
            NSMutableArray<NSNumber *> *itemIDs = [[NSMutableArray<NSNumber *> alloc] init];
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NSMutableArray<GalerieItem *> *items = [[NSMutableArray<GalerieItem *> alloc] init];
                
                for(NSDictionary *itemDictionary in jsonItems) {
                    if(VALID_NOTEMPTY(itemDictionary, NSDictionary)) {
                        GalerieItem *item = nil;
                        
                        if(VALID_NOTEMPTY([itemDictionary objectForKey:@"Id"], NSNumber)) {
                            NSNumber *id = [itemDictionary objectForKey:@"Id"];
                            
                            item = [GalerieItem MR_findFirstByAttribute:@"id" withValue:id inContext:localContext];
                        }
                        
                        if(!VALID(item, GalerieItem)) {
                            item = [GalerieItem fromDictionary:itemDictionary inContext:localContext];
                        }
                        
                        if(VALID(item, GalerieItem)) {
                            [item deserialize:itemDictionary];
                            [items addObject:item];
                            [itemIDs addObject:@(item.id)];
                        }
                    }
                }
                
                outItems = items;
            }];
            
            NSMutableArray<GalerieItem *> *items = [[NSMutableArray<GalerieItem *> alloc] init];
            
            for(NSNumber *itemID in itemIDs)
            {
                GalerieItem *item = [GalerieItem MR_findFirstByAttribute:@"id" withValue:itemID];
                
                if(VALID(item, GalerieItem)) {
                    [items addObject:item];
                }
            }
            
            outItems = items;
            
            outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NewsItem *a = obj1;
                NewsItem *b = obj2;
                
                return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock) {
                    successBlock(outItems);
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil]);
                }
            });
        }
    }];
    
    [dataTask resume];
}

-(void)fetchNewsAtPage:(NSInteger)page objectType:(NSInteger)objectType categoryId:(NSInteger)categoryId withSuccessBlock:(void(^)(NSArray<NewsItem *> *items))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];
    
    NSString *url = [NSString stringWithFormat:kURLLastNewsFormat,
                     [[NSNumber numberWithInt:[[DataManager singleton] isRFJ] ? kZoneIDRFJ : [[DataManager singleton] isRJB] ? kZoneIDRJB : kZoneIDRTN] stringValue], [[NSNumber numberWithInteger:objectType] stringValue], @"0", [[NSNumber numberWithInteger:page] stringValue], [[NSNumber numberWithInteger:categoryId] stringValue]];
    
    
    NSError *urlError = nil;
    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:&urlError];
    
    __block NSArray<NewsItem *> *outItems = [NewsItem MR_findAll];

    outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NewsItem *a = obj1;
        NewsItem *b = obj2;
        
        return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
    }];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock(error);
                }
            });
        }
        else if(VALID(responseObject, NSArray)) {
            NSArray *jsonItems = responseObject;
            
            NSMutableArray<NSNumber *> *itemIDs = [[NSMutableArray<NSNumber *> alloc] init];
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
                
                for(NSDictionary *itemDictionary in jsonItems) {
                    if(VALID_NOTEMPTY(itemDictionary, NSDictionary)) {
                        NewsItem *item = nil;
                        
                        if(VALID_NOTEMPTY([itemDictionary objectForKey:@"Id"], NSNumber)) {
                            NSNumber *id = [itemDictionary objectForKey:@"Id"];
                            
                            item = [NewsItem MR_findFirstByAttribute:@"id" withValue:id inContext:localContext];
                        }
                        
                        if(!VALID(item, NewsItem)) {
                            item = [NewsItem fromDictionary:itemDictionary inContext:localContext];
                        }
                        
                        if(VALID(item, NewsItem)) {
                            [item deserialize:itemDictionary];
                            [items addObject:item];
                            [itemIDs addObject:@(item.id)];
                        }
                    }
                }
            }];
            
            NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
            
            for(NSNumber *itemID in itemIDs)
            {
                NewsItem *item = [NewsItem MR_findFirstByAttribute:@"id" withValue:itemID];
                
                if(VALID(item, NewsItem)) {
                    [items addObject:item];
                }
            }
            
            outItems = items;
            
            outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NewsItem *a = obj1;
                NewsItem *b = obj2;
                
                return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock) {
                    successBlock(outItems);
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil]);
                }
            });
        }
    }];
    
    [dataTask resume];
}

-(void)fetchNewsDetailForNews:(NSInteger)newsID successBlock:(void(^)(NewsDetail *newsDetail))successBlock andFailureBlock:(void(^)(NSError *error, NewsDetail *oldNewsDetail))failureBlock {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];
    
    NSString *url = [NSString stringWithFormat:kURLNewsDetailsFormat, [[NSNumber numberWithInteger:newsID] stringValue]];
    NSError *urlError;
    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:&urlError];
    __block NewsDetail *outDetail = [NewsDetail MR_findFirstByAttribute:@"id" withValue:@(newsID)];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock(error, outDetail);
                }
            });
        }
        else if(VALID(responseObject, NSDictionary)) {
            NSDictionary *jsonObject = responseObject;
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                if(!VALID(outDetail, NewsDetail)) {
                    outDetail = [NewsDetail MR_createEntityInContext:localContext];
                }
                else {
                    outDetail = [NewsDetail MR_findFirstByAttribute:@"id" withValue:@(newsID) inContext:localContext];
                }
                
                [outDetail deserialize:jsonObject];
            }];
            
            outDetail = [NewsDetail MR_findFirstByAttribute:@"id" withValue:@(newsID)];
            
            if(VALID(outDetail, NewsDetail)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(successBlock) {
                        successBlock(outDetail);
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(failureBlock) {
                        failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil], outDetail);
                    }
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil], outDetail);
                }
            });
        }
    }];
    
    [dataTask resume];
}

-(void)fetchImagesAtPage:(NSInteger)page objectType:(NSInteger)objectType categoryId:(NSInteger)categoryId withSuccessBlock:(void(^)(NSArray<GalerieItem *> *photos))successBlock andFailureBlock:(void(^)(NSError *error))failureBlock {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];
    
    NSString *url = [NSString stringWithFormat:kURLLastNewsFormat,
                     [[NSNumber numberWithInt:[[DataManager singleton] isRFJ] ? kZoneIDRFJ : [[DataManager singleton] isRJB] ? kZoneIDRJB : kZoneIDRTN] stringValue], [[NSNumber numberWithInteger:objectType] stringValue], @"1", [[NSNumber numberWithInteger:page] stringValue], [[NSNumber numberWithInteger:categoryId] stringValue]];
    
    
    NSError *urlError = nil;
    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:&urlError];
    
    __block NSArray<GalerieItem *> *outItems = [GalerieItem MR_findAll];
    
    outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GalerieItem *a = obj1;
        GalerieItem *b = obj2;
        
        return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
    }];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock(error);
                }
            });
        }
        else if(VALID(responseObject, NSArray)) {
            NSArray *jsonItems = responseObject;
            
            NSMutableArray<NSNumber *> *itemIDs = [[NSMutableArray<NSNumber *> alloc] init];
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NSMutableArray<GalerieItem *> *photos = [[NSMutableArray<GalerieItem *> alloc] init];
                
                for(NSDictionary *itemDictionary in jsonItems) {
                    if(VALID_NOTEMPTY(itemDictionary, NSDictionary)) {
                        GalerieItem *photo = nil;
                        
                        if(VALID_NOTEMPTY([itemDictionary objectForKey:@"Id"], NSNumber)) {
                            NSNumber *id = [itemDictionary objectForKey:@"Id"];
                            
                            photo = [GalerieItem MR_findFirstByAttribute:@"id" withValue:id inContext:localContext];
                        }
                        
                        if(!VALID(photo, GalerieItem)) {
                            photo = [GalerieItem fromDictionary:itemDictionary inContext:localContext];
                        }
                        
                        if(VALID(photo, GalerieItem)) {
                            [photo deserialize:itemDictionary];
                            [photos addObject:photo];
                            [itemIDs addObject:@(photo.id)];
                        }
                    }
                }
            }];
            
            NSMutableArray<GalerieItem *> *photos = [[NSMutableArray<GalerieItem *> alloc] init];
            
            for(NSNumber *itemID in itemIDs)
            {
                GalerieItem *photo = [GalerieItem MR_findFirstByAttribute:@"id" withValue:itemID];
                
                if(VALID(photo, GalerieItem)) {
                    [photos addObject:photo];
                }
            }
            
            outItems = photos;
            
            outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                GalerieItem *a = obj1;
                GalerieItem *b = obj2;
                
                return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(successBlock) {
                    successBlock(outItems);
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil]);
                }
            });
        }
    }];
    
    [dataTask resume];
}

@end
