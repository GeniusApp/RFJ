//
//  NewsDetailViewController.h
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem+CoreDataProperties.h"

@interface NewsDetailViewController : UIViewController
@property (strong, nonatomic) NSNumber *currentNews;
@property (strong, nonatomic) NSNumber *newsIndex;

-(void)loadNews:(NSNumber *)newsToDisplay;

@end
