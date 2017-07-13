//
//  NSDateFormatterInstance.m
//  rfj
//
//  Created by Denis Pechernyi on 7/12/17.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "NSDateFormatterInstance.h"

@implementation NSDateFormatterInstance {
    NSDateFormatter * formatter_full;
}

- (id) init {
    self = [super init];
    if(self) {
        formatter_full = [[NSDateFormatter alloc] init];
        [formatter_full setDateFormat:@"'Actualisé le' dd.MM.y - HH:mm"];
        [formatter_full setTimeZone:[NSTimeZone localTimeZone]];
    }
    return self;
}

+ (NSDateFormatterInstance*)single {
    static NSDateFormatterInstance * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    return shared;
}

+(NSString*)formatFull:(NSDate*)date {
    return [[NSDateFormatterInstance single]->formatter_full stringFromDate:date];
}

@end
