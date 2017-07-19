//
//  SplashViewController.m
//  rfj
//
//  Created by Gonçalo Girão on 03/07/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "SplashViewController.h"
#import "Validation.h"

@interface SplashViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *splashWebView;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Splash";
    self.splashWebView.delegate = self;
    NSString *interstitialURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJSPLASH&horizontalSize=1080&verticalSize=1920";
    [self getJsonResponse:interstitialURL success:^(NSDictionary *responseDict) {
        
        NSString *str = responseDict[@"banner"];
        NSString *header = @"<style>img{max-width: 100%; width:auto; height: auto;}</style><link rel=\"stylesheet\" href=\"http://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.css\" type=\"text/css\" media=\"all\" /><link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/app.css\" type=\"text/css\" media=\"all\" /><link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/webview.css\" type=\"text/css\" media=\"all\" />";
        if (VALID_NOTEMPTY(str, NSString)){
        str = [header stringByAppendingString:str];
        [self.splashWebView loadHTMLString:str baseURL:nil];
        }
    } failure:^(NSError *error) {
        // error handling here ...
    }];


    // Do any additional setup after loading the view.
}

- (IBAction)closeSplash:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getJsonResponse:(NSString *)urlStr success:(void (^)(NSDictionary *responseDict))success failure:(void(^)(NSError* error))failure
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // Asynchronously API is hit here
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                                NSLog(@"%@",data);
                                                if (error)
                                                failure(error);
                                                else {
                                                    NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                                    NSLog(@"JSON %@",json);
                                                    success(json);
                                                }
                                            }];
    [dataTask resume];    // Executed First
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [BaseViewController gaiTrackEventAd:@"Splash"];
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[request URL] options:@{} completionHandler:nil];
        return NO;
    }
    
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
