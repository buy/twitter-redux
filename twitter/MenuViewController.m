//
//  MenuViewController.m
//  twitter
//
//  Created by Chang Liu on 11/16/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeTimelineViewController.h"
#import "ProfileViewController.h"
#import "User.h"
#import "MenuCell.h"
#import "UIImageView+AFNetworking.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong, nonatomic) UIViewController *profileViewController;
@property (strong, nonatomic) UIViewController *homeTimelineViewController;
@property (strong, nonatomic) NSMutableArray *contentViewControllerArray;

- (IBAction)onLogout:(id)sender;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initContentViewControllers];
    [self loadUser];
    [self initializeTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Initializers

- (void)loadUser {
    User *user = [User currentUser];
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.profileImage.layer.cornerRadius = 5;
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = user.screenName;
}

- (void)initContentViewControllers {
    self.homeTimelineViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeTimelineViewController alloc] init]];
    self.profileViewController = [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] init]];

    self.contentViewControllerArray = [[NSMutableArray alloc] init];

    [self.contentViewControllerArray addObjectsFromArray:@[
                @{@"icon":@"TwitterMenu", @"label":@"Home Timeline", @"controller": self.homeTimelineViewController},
                @{@"icon":@"Profile", @"label":@"Profile", @"controller": self.profileViewController}
    ]];

    self.hamburgerViewController.contentViewController = self.homeTimelineViewController;
}

- (void)initializeTableView {
    self.menuTableView.dataSource = self;
    self.menuTableView.delegate = self;

    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuCell" bundle:nil] forCellReuseIdentifier:@"MenuCell"];
    
    self.menuTableView.estimatedRowHeight = 30;
    self.menuTableView.rowHeight = UITableViewAutomaticDimension;
    self.menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentViewControllerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [self.menuTableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;

    cell.data = self.contentViewControllerArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    self.hamburgerViewController.contentViewController = self.contentViewControllerArray[indexPath.row][@"controller"];
}

- (IBAction)onLogout:(id)sender {
    [User logout];
}

@end
