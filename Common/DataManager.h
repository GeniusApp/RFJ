//
//  DataManager.h
//  rfj
//
//  Created by Nuno Silva on 22/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Singleton.h"

@interface DataManager : NSObject

@property (nonatomic, strong) NSDictionary *backendURLs;
@property (nonatomic, strong) NSDictionary *soapConfig;
@property (nonatomic, strong) NSDictionary *adsAndStatisticConfig;

- (BOOL)isRFJ;
- (BOOL)isRJB;
- (BOOL)isRTN;

-(void)sendInfoReportWithTitle:(NSString *)title name:(NSString *)name firstName:(NSString *)firstName address:(NSString *)address zipCode:(NSString *)zipCode city:(NSString *)city email:(NSString *)email description:(NSString *)description phone:(NSString *)phone image:(NSData *)image successBlock:(void(^)())successBlock
               andFailureBlock:(void(^)(NSError *error))failureBlock;

@end
