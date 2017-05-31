//
//  NewsDetailViewController.m
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "BDGShare.h"
#import "NewsDetailViewController.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "NewsManager.h"
#import "NewsSeparatorViewWithBackButton.h"
#import "ResourcesManager.h"
#import "RadioManager.h"
#import "Validation.h"
#import "DataManager.h"
#import "CategoryViewController.h"
#import "WebViewController.h"

@interface NewsDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *coverImageDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageHeight;
@property (weak, nonatomic) IBOutlet UIWebView *newsContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsContentHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NewsSeparatorViewWithBackButton *separatorView;

@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;
@property (strong, nonatomic) NewsDetail *newsDetail;
@property (assign, nonatomic) NSInteger remainingLoadingElements;
@property (strong, nonatomic) NSString *shareBaseURL;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allMenuItems = [MenuItem MR_findAll];
    
    self.newsContent.scrollView.scrollEnabled = NO;
    
    if([[DataManager singleton] isRFJ]) {
        self.shareBaseURL = kShareURLRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.shareBaseURL = kShareURLRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.shareBaseURL = kShareURLRTN;
    }
    
    [self showLoading];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self.separatorView setUserInteractionEnabled:YES];
    [self.separatorView addGestureRecognizer:gestureRecognizer];
}

-(void)loadNews:(NSNumber *)newsToDisplay {
    [self showLoading];
    self.remainingLoadingElements = 2;
    
    if(VALID(newsToDisplay, NSNumber)) {
        self.currentNews = newsToDisplay;
        
        [[NewsManager singleton] fetchNewsDetailForNews:[newsToDisplay integerValue] successBlock:^(NewsDetail *newsDetail) {
            self.newsDetail = newsDetail;
            
            [self refreshNews];
        } andFailureBlock:^(NSError *error, NewsDetail *oldNewsDetail) {
            self.newsDetail = oldNewsDetail;
            
            [self refreshNews];
        }];
    }
}

-(void)showLoading {
    [self.loadingView setHidden:NO];
}

-(void)hideLoading {
    [self.loadingView setHidden:YES];
}

-(void)refreshNews {
    if(VALID(self.newsDetail, NewsDetail)) {
        self.newsTitleLabel.text = self.newsDetail.title;
        
        self.remainingLoadingElements = 2;
        [self showLoading];

        self.coverImageDescription.text = @"";
        
        NSString *categoryName = @"";
        
        NSInteger categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.id == self.newsDetail.navigationId;
        }];
        
        if(categoryIndex != NSNotFound) {
            categoryName = [self.allMenuItems objectAtIndex:categoryIndex].name;
        }
        
        [self.separatorView setCategoryName:categoryName];
        NSLog(@"DETALHES: %lld", self.newsDetail.navigationId);
        NSString *html = nil;
        
#if kNewsDetailIsHTML
        html = self.newsDetail.content;
#else
        html = [MMMarkdown HTMLStringWithMarkdown:self.newsDetail.content error:nil];
#endif
        
        NSString *header = @"";
        NSString *footer = @"";
        
        Resources *resources = [ResourcesManager resources];
        
        if(VALID(resources, Resources)) {
            if(VALID_NOTEMPTY(resources.htmlHeader, NSString)) {
                header = resources.htmlHeader;
            }

            if(VALID_NOTEMPTY(resources.htmlFooter, NSString)) {
                footer = resources.htmlFooter;
            }
        }
        
        html = [NSString stringWithFormat:@"%@\n%@\n%@", header, html, footer];
        
        [self.newsContent loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
        
        [self.separatorView setDate:self.newsDetail.updateDate];
        
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.newsDetail.image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(!VALID(error, NSError) && VALID(image, UIImage)) {
                self.coverImageView.image = image;
                
                self.coverImageHeight.constant = self.coverImageView.frame.size.width / (float)image.size.width * image.size.height;
            }
            else {
                self.coverImageHeight.constant = 0;
                self.coverImageDescription.text = @"";
            }

            self.remainingLoadingElements--;
            
            if(self.remainingLoadingElements == 0) {
                [self hideLoading];
            }
        }];
        //NSLog(@"HTML: %@", self.newsDetail);
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to load the news article" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Go Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    CategoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryViewController"];
    
    if(VALID(controller, CategoryViewController)) {
        
        controller.navigationId = @(self.newsDetail.navigationId);
        [self.navigationController pushViewController:controller animated:YES];
    }
    //Do stuff here...


}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareFacebook:(id)sender {
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];

    [BDGSharing shareFacebook:self.newsDetail.title urlStr:url image:nil completion:nil];
}

- (IBAction)shareTwitter:(id)sender {
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];
    
    [BDGSharing shareTwitter:self.newsDetail.title urlStr:url image:nil completion:nil];
}

- (IBAction)shareWhatsapp:(id)sender {
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];
    
    NSURL *whatsAppUrl = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@", [[NSString stringWithFormat:@"%@ %@", self.newsDetail.title, url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];

    if ([[UIApplication sharedApplication] canOpenURL:whatsAppUrl]) {
        if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:whatsAppUrl options:@{} completionHandler:nil];
        }
        else {
            [[UIApplication sharedApplication] openURL:whatsAppUrl];
        }
    }
}

- (IBAction)shareLink:(id)sender {
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];
    
    [BDGSharing shareEmail:self.newsDetail.title mailBody:url recipients:nil isHTML:NO completion:nil];
}

#pragma mark - WebView Delegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    //Disable selection
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];

    self.newsContentHeightConstraint.constant = webView.scrollView.contentSize.height;
    
    self.remainingLoadingElements--;
    
    if(self.remainingLoadingElements == 0) {
        [self hideLoading];
    }
}

@end
