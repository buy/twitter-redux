//
//  LoginViewController.m
//  twitter
//
//  Created by Chang Liu on 11/8/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "LoginViewController.h"
#import "HamburgerViewController.h"
#import "TwttierClient.h"

@interface LoginViewController ()

- (IBAction)onLogin:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user) {
            NSLog(@"[INFO] Welcome %@", user.name);
            [self initHomeTimelineView];
        }
        else {
            NSLog(@"[ERROR] Eorror fetching user: %@", error);
        }
    }];
}

#pragma mark - Initializers

- (void)initHomeTimelineView {
    HamburgerViewController *hamburgerViewController = [[HamburgerViewController alloc] init];
    UINavigationController *hamburgerNavigationController = [[UINavigationController alloc] initWithRootViewController:hamburgerViewController];
    [self presentViewController:hamburgerNavigationController animated:YES completion:nil];
}

- (void)initNavigationHeader {
    self.title = @"Twitter";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

@end
