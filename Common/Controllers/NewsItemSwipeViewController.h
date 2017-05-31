//
//  NewsItemSwipeViewController.h
//  rfj
//
//  Created by Gonçalo Girão on 31/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem+CoreDataProperties.h"

@class NewsItemSwipeViewController;
@protocol NewsItemSwipeDelegate<NSObject>
-(void)NewsItemDidTap:(NewsItemSwipeViewController *)item;
@end

@interface NewsItemSwipeViewController : UIViewController
@property (assign, nonatomic) id<NewsItemSwipeDelegate> delegate;
@property (strong, nonatomic) NewsItem *item;

@end
