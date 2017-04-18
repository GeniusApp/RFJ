//
//  ResourcesManager.m
//  rfj
//
//  Created by Nuno Silva on 10/04/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <MagicalRecord/MagicalRecord.h>
#import "Constants.h"
#import "Validation.h"
#import "ResourcesManager.h"

@implementation ResourcesManager

+(Resources *)resources {
    return [Resources MR_findFirst];
}

-(void)fetchResourcesWithSuccessBlock:(void(^)(Resources *resources))successBlock andFailureBlock:(void(^)(NSError *error, Resources *oldResources))failureBlock {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:kURLUsername password:kURLPassword];
    
    NSArray<NSString *> *elementNames = @[@"header", @"footer"];
    
    __block Resources *outResources = [Resources MR_findFirst];
    __block NSInteger numberOfElementsRemaining = 2;
    
    for(NSString *resourceName in elementNames)
    {
        NSString *url = [NSString stringWithFormat:kURLResourcesFormat, resourceName];
        
        NSError *urlError = nil;
        NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:&urlError];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if(VALID(error, NSError)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(failureBlock) {
                        failureBlock(error, outResources);
                    }
                });
            }
            else if(VALID_NOTEMPTY(responseObject, NSDictionary)) {
                NSDictionary *jsonItem = responseObject;
                __block NSManagedObjectID *objectID = nil;
                
                [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                    if(!VALID(outResources, Resources)) {
                        outResources = [Resources MR_createEntityInContext:localContext];
                    }
                    
                    if(VALID(outResources, Resources)) {
                        Resources *localResources = [outResources MR_inContext:localContext];
                        objectID = localResources.objectID;
                        
                        if(VALID_NOTEMPTY([jsonItem objectForKey:@"Resources"], NSString)) {
                            if([resourceName isEqualToString:@"header"]) {
                                localResources.htmlHeader = [jsonItem objectForKey:@"Resources"];
                            }
                            else if([resourceName isEqualToString:@"footer"]) {
                                localResources.htmlFooter = [jsonItem objectForKey:@"Resources"];
                            }
                        }
                    }
                }];
                
                outResources = [[NSManagedObjectContext MR_defaultContext] existingObjectWithID:objectID error:&error];
                
                if(!VALID(outResources, Resources)) {
                    outResources = nil;
                }
                
                numberOfElementsRemaining--;
                
                if(numberOfElementsRemaining == 0) {
                    if(VALID(outResources, Resources)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(successBlock) {
                                successBlock(outResources);
                            }
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(failureBlock) {
                                failureBlock(error, [Resources MR_findFirst]);
                            }
                        });
                    }
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(failureBlock) {
                        failureBlock([NSError errorWithDomain:@"internal" code:0 userInfo:nil], [Resources MR_findFirst]);
                    }
                });
            }
        }];
        
        [dataTask resume];
    }
}

@end
