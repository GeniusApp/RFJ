//
//  CategoryViewController.m
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "Constants.h"
#import "DataManager.h"
#import "Validation.h"
#import "CategoryViewController.h"
#import "GalerieViewController.h"
#import "GalerieDetailViewController.h"
#import "GalerieGroupViewController.h"
#import "GalerieItem+CoreDataProperties.h"
#import "GalerieItemTableViewCell.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "MenuManager.h"
#import "NewsCategorySeparatorView.h"
#import "NewsGroupViewController.h"
#import "NewsItem+CoreDataProperties.h"
#import "NewsItemTableViewCell.h"
#import "NewsDetailViewController.h"
#import "NewsManager.h"
#import "NewsSeparatorViewWithBackButton.h"
#import "RadioManager.h"
#import "WebViewController.h"
#import "WebViewTableViewCell.h"


@interface CategoryViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GADInterstitialDelegate,
NewsItemTableViewCellDelegate, MenuItemTableViewCellDelegate, GalerieItemTableViewCellDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NewsSeparatorViewWithBackButton *separatorView;
@property (weak, nonatomic) IBOutlet UIWebView *bottomBanner;
@property (strong, nonatomic) NSMutableArray<MenuItem *> *menuItems;
@property (strong, nonatomic) NSArray<NewsItem *> *newsItems;
@property (strong, nonatomic) NSArray<GalerieItem *> *galeriePhotos;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<GalerieItem *> *> *sortedGalerieItems;
@property (strong, nonatomic) NSArray<NewsItem *> *newsItemsExtracted;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *expandedMenuItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL isLoading;

@property (strong, nonatomic) NSNumber *activeCategoryId;

@property (strong, nonatomic) DFPBannerView  *bannerView;

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.contentTableView;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refreshControl;

    
    self.allMenuItems = [MenuItem sortedMenuItems];
    self.newsItems = [NewsItem MR_findAll];
    self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                               ascending:NO];
    [self sortGalerieItems];
    [self refreshMenuItems];
    
    if([[DataManager singleton] isRFJ]) {
        self.menuTableView.backgroundColor = kBackgroundColorRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.menuTableView.backgroundColor = kBackgroundColorRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.menuTableView.backgroundColor = kBackgroundColorRTN;
    }
    
    self.expandedMenuItems = [[NSMutableArray<NSNumber *> alloc] init];
    self.activeCategoryId = self.navigationId;
    [self refreshCategory:[self.activeCategoryId intValue]];
    self.currentPage = 0;
    
    self.menuHeightConstraint.constant = 0;
    self.isLoading = NO;
    
    

    

    NSString *banner = @"<link rel=\"stylesheet\" href=\"http://geniusapp.com/webview.css\" type=\"text/css\" media=\"all\" />";
    banner = [banner stringByAppendingString:@"<div class=\"pub\"><img src='https://ww2.lapublicite.ch/pubserver/www/delivery/avw.php?zoneid=20049&amp;cb=101&amp;n=a77eccf9' border='0' alt='' /></div>"];
    NSString *bannerURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJAPPBAN";
    [self getJsonResponse:bannerURL success:^(NSDictionary *responseDict) {
        NSString *str = responseDict[@"banner"];
        NSString *fixBanner = @"<link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/webview.css\" type=\"text/css\" media=\"all\" />";
        str = [fixBanner stringByAppendingString:str];
        [self.bottomBanner loadHTMLString:str baseURL:nil];
    } failure:^(NSError *error) {
        // error handling here ...
    }];

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
                                                    //                                                    NSLog(@"%@",json);
                                                    success(json);
                                                }
                                            }];
    [dataTask resume];    // Executed First
}
- (void)refreshTable:(id)sender {
    //TODO: refresh your data
    
    //[self.contentTableView reloadData];
    [self loadNextPage];
    [self.contentTableView.refreshControl endRefreshing];
    
    
}
-(void)sortGalerieItems {
    self.sortedGalerieItems = [[NSMutableDictionary<NSNumber *, NSArray<GalerieItem *> *> alloc] init];
    
    for(GalerieItem *item in self.galeriePhotos) {
        NSArray *sortedItems = nil;
        
        if([self.sortedGalerieItems objectForKey:@(item.navigationId)] == nil) {
            sortedItems = [NSArray arrayWithObject:item];
        }
        else {
            sortedItems = [[self.sortedGalerieItems objectForKey:@(item.navigationId)] arrayByAddingObject:item];
        }
        
        [self.sortedGalerieItems setObject:sortedItems forKey:@(item.navigationId)];
        
    }
}
- (IBAction)homeButtonTapped:(UIButton *)sender {
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
}

- (IBAction)openInfoReport:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"infoReportViewController"];
    
    if(VALID(controller, UIViewController)) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (IBAction)toggleSound:(UIButton *)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"couper_son_.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else {
        [sender setImage:[UIImage imageNamed:@"ecouter"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
}

-(void)refreshCategory:(NSInteger)categoryId
{
    NSInteger menuIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.id == categoryId;
    }];
    
    if(menuIndex == NSNotFound) {
        return;
    }
    
    self.activeCategoryId = @(categoryId);
    self.currentPage = 1;
    self.newsItems = @[];

    [self.separatorView setCategoryName:[self.allMenuItems objectAtIndex:menuIndex].name];
    
    [self showLoading];
    if ([self.activeCategoryId isEqualToNumber:[NSNumber numberWithInt:9589]]) {
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9611 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9612 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9613 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9614 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9615 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
    } else if ([self.activeCategoryId isEqualToNumber:[NSNumber numberWithInt:9618]]) {
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9643 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9644 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9645 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9646 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9647 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9648 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9649 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9650 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:9829 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:10215 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:10216 withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
    } else {
        [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:categoryId withSuccessBlock:^(NSArray<NewsItem *> *items) {
            self.newsItems = [self.newsItems arrayByAddingObjectsFromArray:items];
            NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
            NSArray *sortDescriptors = @[createDateDescriptor];
            self.newsItems = [self.newsItems sortedArrayUsingDescriptors:sortDescriptors];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error) {
            //NSLog(@"Failure getting news items: %@", error);
            
            [self.contentTableView reloadData];
            [self hideLoading];
        }];
    }
}

-(void)refreshMenuItems
{
    NSMutableArray<MenuItem *> *menuItems = [[NSMutableArray<MenuItem *> alloc] init];
    
    for(MenuItem *item in self.allMenuItems)
    {
        if(item.parentId == 0)
        {
            [menuItems addObject:item];
            
            if([self.expandedMenuItems containsObject:@(item.id)])
            {
                for(MenuItem *childItem in self.allMenuItems)
                {
                    if(childItem.parentId == item.id)
                    {
                        [menuItems addObject:item];
                    }
                }
            }
        }
    }
    
    self.menuItems = menuItems;
    
    [self.menuTableView reloadData];
}

-(void)showLoading {
    [self.loadingView setHidden:NO];
}

-(void)hideLoading {
    [self.loadingView setHidden:YES];
}

-(void)showMenu {
    self.menuHeightConstraint.constant = self.menuTableView.contentSize.height;
    
    [UIView animateWithDuration:kMenuAnimationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)hideMenu {
    self.menuHeightConstraint.constant = 0;
    
    [UIView animateWithDuration:kMenuAnimationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)playRadio:(id)sender {
    if([[RadioManager singleton] isPlaying]) {
        [[RadioManager singleton] stop];
    }
    else {
        [[RadioManager singleton] play];
    }
}

-(void)loadPageItemsForPage:(NSInteger)page count:(NSInteger)count
                    success:(void(^)(NSArray<NewsItem *> *items))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    self.isLoading = YES;
    
    [[NewsManager singleton] fetchNewsAtPage:page objectType:0 withSuccessBlock:^(NSArray<NewsItem *> *items) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(successBlock) {
                successBlock(items);
            }
        });
    } andFailureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(failureBlock) {
                failureBlock(error);
            }
        });
    }];
}
-(void)loadImagesForPage:(NSInteger)page count:(NSInteger)count
                 success:(void(^)(NSArray<GalerieItem *> *photos))successBlock
                 failure:(void(^)(NSError *error))failureBlock {
    self.isLoading = YES;
    NSLog(@"LOADIMAGESFORPAGE");
    [[NewsManager singleton] fetchImagesAtPage:page objectType:1 categoryId:-1 withSuccessBlock:^(NSArray<GalerieItem *> *photos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(successBlock) {
                successBlock(photos);
            }
        });
    } andFailureBlock:^(NSError *error) {
        NSLog(@"LOADIMAGESFORPAGEFAILURE");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(failureBlock) {
                failureBlock(error);
            }
        });
    }];
}
-(void)loadNextPage {
    if(self.isLoading) {
        return;
    }
    
    [self showLoading];
    
    self.currentPage++;
    
    [self loadPageItemsForPage:self.currentPage count:kItemsPerPage success:^(NSArray<NewsItem *> *items) {
        [self hideLoading];
        
        for(NewsItem *item in items) {
            NSInteger itemIndex = [self.newsItems indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return item.id == obj.id;
            }];
            
            if(itemIndex == NSNotFound) {
                self.newsItems = [self.newsItems arrayByAddingObject:item];
            }
        }
        self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                                   ascending:NO];
        [self sortGalerieItems];
        [self.contentTableView reloadData];
    } failure:^(NSError *error) {
        [self hideLoading];
        self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                                   ascending:NO];
        [self sortGalerieItems];
    }];
    [self loadImagesForPage:self.currentPage count:kItemsPerPage success:^(NSArray<GalerieItem *> *photos) {
        [self hideLoading];
        
        for(GalerieItem *photo in photos) {
            NSInteger itemIndex = [self.galeriePhotos indexOfObjectPassingTest:^BOOL(GalerieItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return photo.id == obj.id;
            }];
            
            if(itemIndex == NSNotFound) {
                self.galeriePhotos = [self.galeriePhotos arrayByAddingObject:photo];
            }
        }
        
        self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                                   ascending:NO];
        [self sortGalerieItems];
        [self.contentTableView reloadData];
    } failure:^(NSError *error) {
        [self hideLoading];
        self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                                   ascending:NO];
        [self sortGalerieItems];
    }];
}

- (IBAction)toggleMenu:(id)sender {
    if(self.menuHeightConstraint.constant > 0) {
        [self hideMenu];
    }
    else {
        [self showMenu];
    }
}

#pragma mark - UITableView Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.menuTableView) {
        return [self.menuItems count];
    }
    else if(tableView == self.contentTableView) {
        return [self.newsItems count];
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if(tableView == self.menuTableView)
    {
        MenuItemTableViewCell *actualCell = (MenuItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell"];
        
        if(!VALID(actualCell, MenuItemTableViewCell))
        {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"MenuItemTableViewCell" owner:self options:nil];
            
            if(VALID_NOTEMPTY(views, NSArray))
            {
                actualCell = [views objectAtIndex:0];
            }
        }
        
        if(VALID(actualCell, MenuItemTableViewCell))
        {
            cell = actualCell;
            
            if(indexPath.row >= 0 && indexPath.row < [self.menuItems count])
            {
                MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
                actualCell.delegate = self;
                
                if ([item.name  isEqual: @"Région"]) {
                    //item.name = @"   Région";
                    
                    //actualCell.layer.backgroundColor = [[UIColor colorWithHexString:@"#0073bf"] CGColor];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                    // cell.layer.backgroundColor = [[UIColor colorWithHexString:@"#000000"] CGColor];
                } else if ([item.name  isEqual: @"Suisse"]) {
                    //item.name = @"   Suisse";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Monde"]) {
                    //item.name = @"   Monde";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Économie"]) {
                    //item.name = @"   Économie";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Culture"]) {
                    //item.name = @"   Culture";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Football"]) {
                    //item.name = @"   Football";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Hockey"]) {
                    //item.name = @"   Hockey";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Basketball"]) {
                    //item.name = @"   Basketball";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Volleyball"]) {
                    //item.name = @"   Volleyball";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Cyclisme"]) {
                    //item.name = @"   Cyclisme";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Ski"]) {
                    // item.name = @"   Ski";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Hippisme"]) {
                    // item.name = @"   Hippisme";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Tennis"]) {
                    // item.name = @"   Tennis";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Autres sports"]) {
                    //item.name = @"   Autres sports";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Sports motorisés"]) {
                    // item.name = @"   Sports motorisés";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Inline hockey"]) {
                    // item.name = @"   Inline hockey";
                    
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else {
                    
                    actualCell.layer.backgroundColor = [[UIColor colorWithHexString:@"#0099ff"] CGColor];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#2182c3"] CGColor];
                }
                actualCell.theNameString = item.name;
                
                BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(obj.parentId == item.id)
                    {
                        return YES;
                    }
                    
                    return NO;
                }] != NSNotFound;
                
                UIImage *icon = nil;
                BOOL theBoolIconInteractionEnabled = NO;
                
                if(shouldExpand && item.id != 0) {
                    icon = [UIImage imageNamed:@"hamburger_menu"];
                    theBoolIconInteractionEnabled = YES;
                }
                else if(VALID_NOTEMPTY(item.link, NSString)) {
                    icon = [UIImage imageNamed:@"link"];
                }
                actualCell.theImage = icon;
                actualCell.theBoolIconInteractionEnabled = theBoolIconInteractionEnabled;
            }
        }
    }
    else if(tableView == self.contentTableView) {
        if (indexPath.row == 7) {
            // Reuse and create cell
            WebViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"webCell"];
            
            if(!VALID(cell, WebViewTableViewCell)) {
                NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"WebViewTableViewCell" owner:self options:nil];
                
                if(VALID_NOTEMPTY(views, NSArray)) {
                    cell = [views objectAtIndex:0];
                }
            }
            NSString *squareURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJPAVE";
            [self getJsonResponse:squareURL success:^(NSDictionary *responseDict) {
                NSString *str = responseDict[@"banner"];
                NSString *fixSquare = @"<div class=\"pub\" id=\"beacon_6b7b3f991\">";
                str = [fixSquare stringByAppendingString:str];
                str = [str stringByAppendingString:@"</div>"];
                [cell.webView loadHTMLString:str baseURL:nil];
                cell.webView.delegate = self;
            } failure:^(NSError *error) {
                // error handling here ...
            }];
            
            return cell;
        } else if (indexPath.row == 14) {
            NSLog(@"GALERIEITEMS: %@", self.galeriePhotos);
            GalerieItemTableViewCell *actualCell = (GalerieItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"galerieItemCell"];
            
            if(!VALID(actualCell, GalerieItemTableViewCell)) {
                NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"GalerieItemTableViewCell" owner:self options:nil];
                
                if(VALID_NOTEMPTY(views, NSArray)) {
                    actualCell = [views objectAtIndex:0];
                }
            }
            
            if(VALID(actualCell, GalerieItemTableViewCell)) {
                cell = actualCell;
                actualCell.delegate = self;
                if(indexPath.row >= 0 && indexPath.row < [self.galeriePhotos count])
                {
                    
                    NSSortDescriptor *createDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
                    NSArray *sortDescriptors = @[createDateDescriptor];
                    self.galeriePhotos = [self.galeriePhotos sortedArrayUsingDescriptors:sortDescriptors];
                    GalerieItem *item = [self.galeriePhotos objectAtIndex:0];
                    actualCell.item = item;
                }
                
                return cell;
            }
        } else if (indexPath.row %14 == 0 && indexPath.row != 14 && indexPath.row != 0) {
            // Reuse and create cell
            WebViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"webCell"];
            
            if(!VALID(cell, WebViewTableViewCell)) {
                NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"WebViewTableViewCell" owner:self options:nil];
                
                if(VALID_NOTEMPTY(views, NSArray)) {
                    cell = [views objectAtIndex:0];
                }
            }
            NSString *squareURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJPAVE";
            [self getJsonResponse:squareURL success:^(NSDictionary *responseDict) {
                NSString *str = responseDict[@"banner"];
                NSString *fixSquare = @"<div class=\"pub\" id=\"beacon_6b7b3f991\">";
                str = [fixSquare stringByAppendingString:str];
                str = [str stringByAppendingString:@"</div>"];
                [cell.webView loadHTMLString:str baseURL:nil];
                cell.webView.delegate = self;
            } failure:^(NSError *error) {
                // error handling here ...
            }];
            
            return cell;
        } else {
            NewsItemTableViewCell *actualCell = (NewsItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"newsItemCell"];
            
            if(!VALID(actualCell, NewsItemTableViewCell))
            {
                NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewsItemTableViewCell" owner:self options:nil];
                
                if(VALID_NOTEMPTY(views, NSArray))
                {
                    actualCell = [views objectAtIndex:0];
                }
            }
            
            if(VALID(actualCell, NewsItemTableViewCell))
            {
                cell = actualCell;
                actualCell.delegate = self;
                if(indexPath.row >= 0 && indexPath.row < [self.newsItems count])
                {
                    NewsItem *item = [self.newsItems objectAtIndex:indexPath.row];
                    
                    actualCell.item = item;
                }
            }
        }
    }
    return cell;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[request URL] options:@{} completionHandler:nil];
        return NO;
    }
    
    return YES;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.menuTableView) {
        return 44.0f;
    }
    else if(tableView == self.contentTableView) {
        if (indexPath.row %14 == 0 || indexPath.row == 7) {
            if (indexPath.row == 0) {
                return ceilf([UIScreen mainScreen].bounds.size.width * 0.6372340425531915);
            } else {
                return 300;
            }
        }  else {
            return ceilf([UIScreen mainScreen].bounds.size.width * 0.6372340425531915);
        }
    }
    
    return 44.0f;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView == self.contentTableView) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height && !self.isLoading) {
            [self loadNextPage];
        }
    }
}

#pragma mark - MenuItemTableViewCell Delegate

-(void)menuItemDidTapIcon:(MenuItemTableViewCell *)item {
    NSIndexPath *index = [self.menuTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.menuItems count]) {
        MenuItem *menuItem = [self.menuItems objectAtIndex:index.row];
        
        if(VALID(menuItem, MenuItem)) {
            if([self.expandedMenuItems containsObject:@(menuItem.id)]) {
                [self.expandedMenuItems removeObject:@(menuItem.id)];
                
                NSMutableArray<NSIndexPath *> *removedRows = [[NSMutableArray<NSIndexPath *> alloc] init];
                
                for(NSInteger i = [self.menuItems count] - 1; i >= 0; i--) {
                    MenuItem *subItem = [self.menuItems objectAtIndex:i];
                    
                    if(VALID(subItem, MenuItem) && subItem.parentId == menuItem.id) {
                        [removedRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        
                        [self.menuItems removeObject:subItem];
                    }
                }
                
                [self.menuTableView deleteRowsAtIndexPaths:removedRows withRowAnimation:UITableViewRowAnimationTop];
                
                self.menuHeightConstraint.constant = self.menuHeightConstraint.constant - [removedRows count] * kMenuRowHeight;
                
                [UIView animateWithDuration:kMenuAnimationTime animations:^{
                    [self.menuTableView beginUpdates];
                    [self.menuTableView endUpdates];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.parentId == menuItem.id;
                }] != NSNotFound;
                
                if(shouldExpand && menuItem.id != 0) {
                    [self.expandedMenuItems addObject:@(menuItem.id)];
                    
                    NSInteger startIndex = index.row + 1;
                    NSInteger currentIndex = 0;
                    NSMutableArray<NSIndexPath *> *insertedRows = [[NSMutableArray<NSIndexPath *> alloc] init];
                    
                    for(MenuItem *subItem in self.allMenuItems)
                    {
                        if(subItem.parentId == menuItem.id)
                        {
                            [self.menuItems insertObject:subItem atIndex:startIndex + currentIndex];
                            [insertedRows addObject:[NSIndexPath indexPathForRow:startIndex + currentIndex inSection:0]];
                            
                            currentIndex++;
                        }
                    }
                    
                    [self.menuTableView insertRowsAtIndexPaths:insertedRows withRowAnimation:UITableViewRowAnimationTop];
                    
                    self.menuHeightConstraint.constant = self.menuHeightConstraint.constant + [insertedRows count] * kMenuRowHeight;
                    
                    [UIView animateWithDuration:kMenuAnimationTime animations:^{
                        [self.menuTableView beginUpdates];
                        [self.menuTableView endUpdates];
                        [self.view layoutIfNeeded];
                    }];
                }
            }
        }
    }
}

-(void)menuItemDidTap:(MenuItemTableViewCell *)item {
    self.menuHeightConstraint.constant = 0;

    NSIndexPath *index = [self.menuTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.menuItems count]) {
        MenuItem *menuItem = [self.menuItems objectAtIndex:index.row];
        
        if(VALID(menuItem, MenuItem)) {
            [self.expandedMenuItems removeAllObjects];
            [self refreshMenuItems];

            if(VALID_NOTEMPTY(menuItem.link, NSString)) {
                WebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
                
                if(VALID(controller, WebViewController)) {
                    controller.url = menuItem.link;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            } else if ([@(menuItem.id) isEqualToNumber:[NSNumber numberWithInt:9622]]) {
                
                GalerieViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GalerieViewController"];
                
                if(VALID(controller, GalerieViewController)) {
                    //controller.navigationId = @(menuItem.id);
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
            else {
                [self refreshCategory:menuItem.id];
            }
        }
    }
}

#pragma mark - NewsItemTableViewCell Delegate

-(void)NewsItemDidTap:(NewsItemTableViewCell *)item {
    //NSLog(@"News GROUP TAPPED");
    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    if(index.row >= 0 && index.row < [self.newsItems count]) {
        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];

        if(VALID(controller, NewsGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NewsItem *localItem = [item.item MR_inContext:localContext];
                
                if(VALID(localItem, NewsItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];

            controller.newsToDisplay = self.newsItems;
            controller.startingIndex = @(index.row);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

@end
