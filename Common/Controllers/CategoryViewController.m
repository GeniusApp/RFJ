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
@property (nonatomic, assign) double theFakeMenuHeightConstraintConstant;
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
    // tableView
    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"MenuItemTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"WebViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"WebViewTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"GalerieItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"GalerieItemTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"NewsItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsItemTableViewCell"];
    
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
#if !(TARGET_IPHONE_SIMULATOR)
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
#endif
    
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
    [self adjustMenuHeightConstant];
    
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
    [[NewsManager singleton] fetchImagesAtPage:page objectType:1 categoryId:-1 withSuccessBlock:^(NSArray<GalerieItem *> *photos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(successBlock) {
                successBlock(photos);
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
    if(tableView == self.menuTableView) {
        static NSString * cellId = @"MenuItemTableViewCell";
        MenuItemTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0099ff"];
        cell.contentView.layer.borderWidth = 1;
        cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#2182c3"] CGColor];
        // TODO AN Refactor. Create .json or .plist instead. DO NOT use isEqual. Use id comparision
        if(
           [item.name  isEqual: @"Région"]              ||
           [item.name  isEqual: @"Suisse"]              ||
           [item.name  isEqual: @"Monde"]               ||
           [item.name  isEqual: @"Économie"]            ||
           [item.name  isEqual: @"Culture"]             ||
           [item.name  isEqual: @"Football"]            ||
           [item.name  isEqual: @"Hockey"]              ||
           [item.name  isEqual: @"Basketball"]          ||
           [item.name  isEqual: @"Volleyball"]          ||
           [item.name  isEqual: @"Cyclisme"]            ||
           [item.name  isEqual: @"Ski"]                 ||
           [item.name  isEqual: @"Hippisme"]            ||
           [item.name  isEqual: @"Tennis"]              ||
           [item.name  isEqual: @"Autres sports"]       ||
           [item.name  isEqual: @"Sports motorisés"]    ||
           [item.name  isEqual: @"Inline hockey"] ) {
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073c0"];
            cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
        }
        cell.theNameString = item.name;
        BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.parentId == item.id;
        }] != NSNotFound;
        
        if(shouldExpand && item.id != 0) {
            cell.theImage = [UIImage imageNamed:@"hamburger_menu"];
            cell.theBoolIconInteractionEnabled = YES;
        } else if(VALID_NOTEMPTY(item.link, NSString)) {
            cell.theImage = [UIImage imageNamed:@"link"];
            cell.theBoolIconInteractionEnabled = NO;
        } else {
            cell.theImage = nil;
            cell.theBoolIconInteractionEnabled = NO;
        }
        return cell;
    } else if(tableView == self.contentTableView) {
        NSInteger arrayIndex = (indexPath.row / 16) - 1;
        if (indexPath.row %16 == 0 && indexPath.row != 0) {
            static NSString * cellId = @"GalerieItemTableViewCell";
            GalerieItemTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
            cell.delegate = self;
            cell.item = self.galeriePhotos[arrayIndex];
            return cell;
        } else if (indexPath.row == 7) {
            static NSString * cellId = @"WebViewTableViewCell";
            WebViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
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
        } else if (indexPath.row %8 == 0 && indexPath.row != 16 && indexPath.row != 0 && indexPath.row != 8) {
            static NSString * cellId = @"WebViewTableViewCell";
            WebViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
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
        }
        // else
        static NSString * cellId = @"NewsItemTableViewCell";
        NewsItemTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.delegate = self;
        [cell setItem:self.newsItems[indexPath.row]];
        return cell;
    }
    return nil;
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
        if (indexPath.row %16 == 0 || indexPath.row == 8 || indexPath.row != 0) {
            return 300;
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
                
                self.menuHeightConstraint.constant = self.theFakeMenuHeightConstraintConstant - [removedRows count] * kMenuRowHeight;
                [self adjustMenuHeightConstant];
                
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
                    
                    self.menuHeightConstraint.constant = self.theFakeMenuHeightConstraintConstant + [insertedRows count] * kMenuRowHeight;
                    [self adjustMenuHeightConstant];
                    
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
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:menuItem.link]];
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
-(void)GalerieItemDidTap:(GalerieItemTableViewCell *)item {
    
    //    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    //    NSLog(@"GALERIE PHOTO TAPPED %ld", (long)index.row);
    //    GalerieItem *photoItem = [self.galerieItems objectAtIndex:index.row];
    //    NSLog(@"GALERIE PHOTO TAPPED %@", photoItem.retina1);
    //    UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoItem.retina1]]];
    //    [self addImageViewWithImage:image];
    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    if(index.row >= 0 && index.row < [self.galeriePhotos count]) {
        GalerieGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"galerieGroup"];
        
        if(VALID(controller, GalerieGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                GalerieItem *localItem = [item.item MR_inContext:localContext];
                
                if(VALID(localItem, GalerieItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
            controller.galerieToDisplay = self.galeriePhotos;
            controller.startingIndex = @([controller.galerieToDisplay indexOfObjectPassingTest:^BOOL(GalerieItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj == item.item;
            }]);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
}

- (void)adjustMenuHeightConstant
{
    self.theFakeMenuHeightConstraintConstant = self.menuHeightConstraint.constant;
    double theProperHeightCount = 0;
    {
    theProperHeightCount += self.menuTableView.superview.frame.size.height;
    theProperHeightCount -= self.bottomBanner.frame.size.height;
    theProperHeightCount -= self.menuTableView.frame.origin.y;
    }
    if (self.menuHeightConstraint.constant > theProperHeightCount)
        {
        self.menuHeightConstraint.constant = theProperHeightCount;
        }
}

@end
