//
//  NewsCategorySeparatorView.h
//  rfj
//
//  Created by Nuno Silva on 21/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsCategorySeparatorView;

@protocol NewsCategorySeparatorViewDelegate<NSObject>
-(void)NewsCategorySeparatorViewDidClickLeft:(NewsCategorySeparatorView *)view;
-(void)NewsCategorySeparatorViewDidClickRight:(NewsCategorySeparatorView *)view;
@end

@interface NewsCategorySeparatorView : UIView

@property (assign, nonatomic) id<NewsCategorySeparatorViewDelegate> delegate;
@property (strong, nonatomic) NSNumber *tableSection;

-(void)setName:(NSString *)name;
@end
