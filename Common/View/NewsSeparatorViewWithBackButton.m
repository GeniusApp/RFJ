//
//  NewsSeparatorViewWithBackButton.m
//  rfj
//
//  Created by Nuno Silva on 01/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "DataManager.h"
#import "NewsSeparatorViewWithBackButton.h"
#import "Validation.h"
#import "Constants.h"
#import "CategoryViewController.h"
#import "GalerieViewController.h"
#import "MainViewController.h"

@interface NewsSeparatorViewWithBackButton()
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation NewsSeparatorViewWithBackButton

-(void)awakeFromNib {
    [super awakeFromNib];
    
    if([[DataManager singleton] isRFJ]) {
        self.backgroundColor = kBackgroundColorRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.backgroundColor = kBackgroundColorRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.backgroundColor = kBackgroundColorRTN;
    }
    
    self.categoryLabel.text = @"";
    self.dateLabel.text = @"";
    
    if(ISEMPTY(self.subviews)) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NewsSeparatorViewWithBackButton" owner:self options:nil];
        
        if(VALID_NOTEMPTY(objects, NSArray)) {
            NewsSeparatorViewWithBackButton *instancedView = [objects objectAtIndex:0];
            
            if(VALID(instancedView, NewsSeparatorViewWithBackButton)) {
                self.categoryLabel = instancedView.categoryLabel;
                self.dateLabel = instancedView.dateLabel;
                
                [self addSubview:instancedView];
                
                NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:instancedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
                
                NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:instancedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
                
                NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:instancedView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
                
                NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:instancedView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
                
                [self addConstraints:@[top, bottom, left, right]];
            }
        }
    }
}

-(void)setDate:(NSDate *)date {
    if(VALID_NOTEMPTY(date, NSDate)) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"'Actualisé le' dd.MM.y - HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        
        self.dateLabel.text = [formatter stringFromDate:date];
    }
}

-(void)setCategoryName:(NSString *)categoryName {
    self.categoryLabel.text = categoryName;
}

- (IBAction)goBack:(id)sender {
    UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    if(VALID(navigationController, UINavigationController)) {
        UIViewController *topController = navigationController.topViewController;
        NSArray<UIViewController *> *controllers = navigationController.viewControllers;
        BOOL wantsMainController = VALID(topController, CategoryViewController);
        
        for(NSInteger i = [controllers count] - 2; i >= 0; i--) {
            UIViewController *controller = [controllers objectAtIndex:i];
            NSLog(@"CONTROLLER: %@", controller);
            NSLog(@"NAVIGATION CONTROLLER: %@", navigationController);
            if((!wantsMainController && VALID(controller, CategoryViewController)) || VALID(controller, MainViewController) || VALID(controller, GalerieViewController)) {
                [navigationController popToViewController:controller animated:YES];
                
                break;
            }
        }
    }
}

@end
