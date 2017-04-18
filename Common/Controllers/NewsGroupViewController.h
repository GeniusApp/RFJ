//
//  NewsGroupViewController.h
//  rfj
//
//  Created by Nuno Silva on 31/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem+CoreDataProperties.h"

@interface NewsGroupViewController : UIViewController
@property (strong, nonatomic) NSArray<NewsItem *> *newsToDisplay;
@property (strong, nonatomic) NSNumber *startingIndex;
@property int iRecordIndex;

@end
