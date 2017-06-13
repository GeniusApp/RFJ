//
//  NewsItemSwipeTableViewCell.h
//  rfj
//
//  Created by Gonçalo Girão on 31/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem+CoreDataProperties.h"

@interface NewsItemSwipeTableViewCell : UITableViewCell
@property (strong, nonatomic) NSArray <NewsItem *> *newsItems;
- (void) moveLeft;
- (void) moveRight;
- (void) display;
@end
