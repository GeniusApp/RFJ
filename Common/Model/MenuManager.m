//
//  MenuManager.m
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <MagicalRecord/MagicalRecord.h>
#import "MenuManager.h"
#import "Validation.h"
#import "Constants.h"
#import "DataManager.h"

@implementation MenuManager

-(void)fetchMenuItemsFromServerWithSuccessBlock:(void(^)(NSArray<MenuItem *> *items))successBlock andFailureBlock:(void(^)(NSError *error, NSArray<MenuItem *> *oldItems))failureBlock
{
    _performedInitialFetch = YES;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];
    NSString *menuListUrl = [NSString stringWithFormat:kURLNavigationFormat,
                             [[NSNumber numberWithInt:[[DataManager singleton] isRFJ] ? kZoneIDRFJ : [[DataManager singleton] isRJB] ? kZoneIDRJB : kZoneIDRTN] stringValue]];

    NSError *urlError = nil;
    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:menuListUrl parameters:nil error:&urlError];
    
    __block NSArray<MenuItem *> *outItems = [MenuItem MR_findAll];
    
    outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MenuItem *a = obj1;
        MenuItem *b = obj2;
        
        return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
    }];
    
    if(!VALID(request, NSURLRequest)) {
        if(failureBlock) {
            failureBlock(urlError, outItems);
        }
        
        return;
    }
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock(error, outItems);
                }
            });
        }
        else if(VALID(responseObject, NSArray)) {
            NSArray *jsonItems = responseObject;

            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                [MenuItem MR_truncateAllInContext:localContext];
                
                NSMutableArray<MenuItem *> *items = [[NSMutableArray<MenuItem *> alloc] init];
                
                MenuItem *infoEnContinuItem = [MenuItem MR_createEntityInContext:localContext];
                infoEnContinuItem.id = 0;
                infoEnContinuItem.name = @"L'info en continu";
                
                [items addObject:infoEnContinuItem];
                
                for(NSDictionary *itemDictionary in jsonItems) {
                    if(VALID_NOTEMPTY(itemDictionary, NSDictionary)) {
                        MenuItem *item = [MenuItem fromDictionary:itemDictionary inContext:localContext];
                            
                        if(VALID(item, MenuItem)) {
                            [items addObject:item];
                        }
                    }
                }
            }];
            
            [self fetchTemporaryNavigationMenuItemsFromServerWithSuccessBlock:successBlock andFailureBlock:failureBlock];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil], outItems);
                }
            });
        }
    }];
    
    [dataTask resume];
}

-(void)fetchTemporaryNavigationMenuItemsFromServerWithSuccessBlock:(void(^)(NSArray<MenuItem *> *items))successBlock andFailureBlock:(void(^)(NSError *error, NSArray<MenuItem *> *oldItems))failureBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];
    NSString *menuListUrl = [NSString stringWithFormat:kURLTemporaryNavigationFormat,
                             [[NSNumber numberWithInt:[[DataManager singleton] isRFJ] ? kZoneIDRFJ : [[DataManager singleton] isRJB] ? kZoneIDRJB : kZoneIDRTN] stringValue]];
    
    NSError *urlError = nil;
    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:menuListUrl parameters:nil error:&urlError];
    
    __block NSArray<MenuItem *> *outItems = [MenuItem MR_findAll];
    
    outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MenuItem *a = obj1;
        MenuItem *b = obj2;
        
        return a.id < b.id ? NSOrderedAscending : a.id > b.id ? NSOrderedDescending : NSOrderedSame;
    }];
    
    if(!VALID(request, NSURLRequest)) {
        if(failureBlock) {
            failureBlock(urlError, outItems);
        }
        
        return;
    }
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(VALID(error, NSError)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failureBlock) {
                    failureBlock(error, outItems);
                }
            });
        }
        else if(VALID(responseObject, NSArray)) {
            NSArray *jsonItems = responseObject;
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NSMutableArray<MenuItem *> *items = [[NSMutableArray<MenuItem *> alloc] init];
                
                for(NSDictionary *itemDictionary in jsonItems) {
                    if(VALID_NOTEMPTY(itemDictionary, NSDictionary)) {
                        MenuItem *item = [MenuItem fromDictionary:itemDictionary inContext:localContext];
                        
                        if(VALID(item, MenuItem)) {
                            [items addObject:item];
                        }
                    }
                }
            }];
            
            outItems = [MenuItem MR_findAll];
            
            outItems = [outItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                MenuItem *a = obj1;
                MenuItem *b = obj2;
                
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
                    failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil], outItems);
                }
            });
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(successBlock) {
            successBlock(outItems);
        }
    });
    
    [dataTask resume];
}

@end
