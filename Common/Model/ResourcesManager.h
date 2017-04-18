//
//  ResourcesManager.h
//  rfj
//
//  Created by Nuno Silva on 10/04/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Singleton.h"
#import "Resources+CoreDataProperties.h"

@interface ResourcesManager : NSObject

-(void)fetchResourcesWithSuccessBlock:(void(^)(Resources *resources))successBlock andFailureBlock:(void(^)(NSError *error, Resources *oldResources))failureBlock;
+(Resources *)resources;

@end
