//
//  MenuManager.h
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuItem+CoreDataProperties.h"
#import "NSObject+Singleton.h"

@interface MenuManager : NSObject
@property (assign, nonatomic, readonly) BOOL performedInitialFetch;

-(void)fetchMenuItemsFromServerWithSuccessBlock:(void(^)(NSArray<MenuItem *> *items))successBlock andFailureBlock:(void(^)(NSError *error, NSArray<MenuItem *> *oldItems))failureBlock;

@end
