//
//  ProfileViewController.m
//  twitter
//
//  Created by Chang Liu on 11/16/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "ProfileViewController.h"
#import "HomeTimelineViewController.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetsCountLabel;
@property (weak, nonatomic) IBOutlet UIView *homeTimelineTableView;

@property (weak, nonatomic) NSString *userID;
@property (strong, nonatomic) UIViewController *homeTimelineViewController;
@property (strong, nonatomic) UITableView *homeTimelineTable;

@end

@implementation ProfileViewController

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    
    if (self) {
        self.userID = data[@"user_id"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initHomeTimelineTable];
    [self initNavigationHeader];
    [self fetchUserData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Initializers

- (void)initHomeTimelineTable {
    NSDictionary *data = @{};

    if (self.userID) {
        data = @{@"user_id": self.userID};
    }

    self.homeTimelineViewController = [[HomeTimelineViewController alloc] initWithDictionary:data];
    [self.homeTimelineViewController.navigationController setNavigationBarHidden:YES];
//    UIEdgeInsets inset = UIEdgeInsetsMake(64, 0, 0, 0);
//    [self.homeTimelineViewController] .contentInset = inset;
//    self.homeTimelineViewController.view.tag = 1;
    [self.homeTimelineTableView addSubview:self.homeTimelineViewController.view];
//    self.homeTimelineTable = (UITableView*)[self.homeTimelineTableView viewWithTag:1];
//    self.homeTimelineTableView.bounds = CGRectInset(self.homeTimelineTableView.frame, 0, 0);
}

- (void)initNavigationHeader {
    self.title = @"Profile";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [settingsView addTarget:self action:@selector(onMenuButton) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[UIImage imageNamed:@"MenuIcon"] forState:UIControlStateNormal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    self.navigationItem.leftBarButtonItem = settingsButton;
}

- (void)fetchUserData {
    if (self.userID) {
        [User getUserWithUserID:self.userID completion:^(User *user, NSError *error) {
            if (user) {
                [self initUserProfile:user];
            }
            else {
                NSLog(@"[ERROR] Failed loading user data");
            }
        }];
    }
    else {
        [self initUserProfile:[User currentUser]];
    }
}

- (void)initUserProfile:(User *)profileUser {
    [self.profileImage setImageWithURL:[NSURL URLWithString:profileUser.profileImageURL]];
    self.profileImage.layer.cornerRadius = 5;
    self.nameLabel.text = profileUser.name;
    self.screenNameLabel.text = profileUser.screenName;
    self.followersCountLabel.text = profileUser.followersCount;
    self.followingCountLabel.text = profileUser.followingCount;
    self.tweetsCountLabel.text = profileUser.statusesCount;
    [self.backgroundImage setImageWithURL:[NSURL URLWithString:profileUser.backgroundImageURL]];
}

# pragma mark - Private method

- (void)onMenuButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:OnMenuButtonNotification object:nil];
}

@end
