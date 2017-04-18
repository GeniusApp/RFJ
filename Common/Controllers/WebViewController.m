//
//  WebViewController.m
//  rfj
//
//  Created by Nuno Silva on 28/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "WebViewController.h"
#import "Constants.h"
#import "DataManager.h"
#import "RadioManager.h"

@interface WebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([[DataManager singleton] isRFJ]) {
        self.returnButton.tintColor = kBackgroundColorRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.returnButton.tintColor = kBackgroundColorRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.returnButton.tintColor = kBackgroundColorRTN;
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)showLoading {
    [self.loadingView setHidden:NO];
}

-(void)hideLoading {
    [self.loadingView setHidden:YES];
}

-(IBAction)playRadio:(id)sender {
    if([[RadioManager singleton] isPlaying]) {
        [[RadioManager singleton] stop];
    }
    else {
        [[RadioManager singleton] play];
    }
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma comment - UIWebView Delegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideLoading];
}

@end
