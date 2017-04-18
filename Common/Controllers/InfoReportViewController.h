//
//  InfoReportViewController.h
//  rfj
//
//  Created by Nuno Silva on 03/04/17.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoViewController;

@interface InfoReportViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) InfoViewController *controller;
//@property (nonatomic) InfoTypeEnum selectedType;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)sendTapped:(id)sender;
- (IBAction)UploadPhoto:(id)sender;

@end
