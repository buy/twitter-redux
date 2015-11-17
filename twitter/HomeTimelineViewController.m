//
//  HomeTimelineViewController.m
//  twitter
//
//  Created by Chang Liu on 11/9/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "HomeTimelineViewController.h"
#import "NewTweetViewController.h"
#import "TweetDetailViewController.h"
#import "User.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "TwttierClient.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"

NSString * const OnMenuButtonNotification = @"OnMenuButtonNotification";

@interface HomeTimelineViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *tweets;
@property (weak, nonatomic) NSString *userID;

@end

@implementation HomeTimelineViewController

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];

    if (self) {
        self.userID = data[@"user_id"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    UIEdgeInsets inset = UIEdgeInsetsMake(64, 0, 0, 0);
//    self.homelineTableView.contentInset = inset;

    [self initializeTableView];
    [self initNavigationHeader];

    [self fetchTweets];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNewTweet:) name:TweetUpdateNofication object:nil];

    [self initInfiniteScroll];
    [self initPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tweet refresher

- (void)initInfiniteScroll {
    [self.homelineTableView addInfiniteScrollingWithActionHandler:^{
        Tweet *tweet = [self.tweets lastObject];
        [self fetchTweets:tweet.tweetID];
    }];
}

- (void)initPullToRefresh {
//    [self.homelineTableView addPullToRefreshWithActionHandler:^{
//        [self fetchTweets:nil];
//    }];
}

#pragma mark - Initializers

- (void)initializeTableView {
    self.homelineTableView.dataSource = self;
    self.homelineTableView.delegate = self;
    
    [self.homelineTableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.homelineTableView.estimatedRowHeight = 50;
    self.homelineTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)initNavigationHeader {
    self.title = @"Twitter";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [settingsView addTarget:self action:@selector(onMenuButton) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[UIImage imageNamed:@"MenuIcon"] forState:UIControlStateNormal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    self.navigationItem.leftBarButtonItem = settingsButton;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(initNewTweetView)];
}

- (void)initNewTweetView {
    NewTweetViewController *newTweetViewController = [[NewTweetViewController alloc] init];

    UINavigationController *newTweetNavigationController = [[UINavigationController alloc] initWithRootViewController:newTweetViewController];
    [self presentViewController:newTweetNavigationController animated:YES completion:nil];
}

- (void)initTweetDetailsView:(Tweet *)tweet {
    TweetDetailViewController *tweetDetailsViewController = [[TweetDetailViewController alloc] initWithTweet:tweet];

    UINavigationController *tweetDetailsNavigationController = [[UINavigationController alloc] initWithRootViewController:tweetDetailsViewController];
    [self presentViewController:tweetDetailsNavigationController animated:YES completion:nil];
    CFRunLoopWakeUp(CFRunLoopGetCurrent());
}

#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [self.homelineTableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;

    Tweet *tweet = self.tweets[indexPath.row];
    cell.tweet = tweet;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    Tweet *tweet = self.tweets[indexPath.row];

    [self initTweetDetailsView:tweet];
}

#pragma mark - API call

-(void)fetchTweets {
    Tweet *lastTweet = [self.tweets lastObject];
    [self fetchTweets:lastTweet.tweetID];
}

- (void)fetchTweets:(NSNumber *)lastTweetID {
    if (!lastTweetID) {
        [MBProgressHUD showHUDAddedTo:self.homelineTableView animated:YES];
    }

    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithDictionary:@{@"count": @20}];

    if (lastTweetID) {
        [requestParams setObject:lastTweetID forKey:@"max_id"];
    }

    if (self.userID) {
        [requestParams setObject:self.userID forKey:@"user_id"];
    }

    [[TwitterClient sharedInstance] fetchTweetsWithCompletion:requestParams completion:^(NSArray *tweets, NSError *error) {
        runOnMainQueueWithoutDeadlocking(^{
            [MBProgressHUD hideHUDForView:self.homelineTableView animated:YES];
            [self.homelineTableView.infiniteScrollingView stopAnimating];
            [self.homelineTableView.pullToRefreshView stopAnimating];

        });

        if (tweets) {
            NSLog(@"[INFO] Fetched %lu tweets", (unsigned long)tweets.count);

            if (lastTweetID) {
                [self.tweets addObjectsFromArray:tweets];
            }
            else {
                self.tweets = [NSMutableArray arrayWithArray:tweets];
            }

            [self.homelineTableView reloadData];
        }
        else {
            NSLog(@"[ERROR] Unable to load tweets");
        }
    }];
}

#pragma mark - Private methods

- (void)onMenuButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:OnMenuButtonNotification object:nil];
}

- (void)gotNewTweet:(NSNotification *)notification {
    if (notification.userInfo[@"tweet"]) {
        [self.tweets insertObject:notification.userInfo[@"tweet"] atIndex:0];
        NSLog(@"[INFO] New tweet added to homeline");
    }

    [self.homelineTableView reloadData];
}

void runOnMainQueueWithoutDeadlocking(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)alertNetworkError {
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Error occurred while connecting to the server, please try again later"
                                                                        preferredStyle:UIAlertControllerStyleAlert                   ];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [myAlertController addAction: ok];
    [self presentViewController:myAlertController animated:YES completion:nil];
}

@end
