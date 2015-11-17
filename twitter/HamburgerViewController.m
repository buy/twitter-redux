//
//  HamburgerViewController.m
//  twitter
//
//  Created by Chang Liu on 11/16/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "HamburgerViewController.h"
#import "HomeTimelineViewController.h"
#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "TweetCell.h"

@interface HamburgerViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@end

@implementation HamburgerViewController

CGFloat originalContentViewLeftMargin;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initMenuView];
    [self initContentView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleMenu) name:OnMenuButtonNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newProfileRequest:) name:OnNewProfileRequestNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Initializers

//need to wait for viewDidLoad before running this, thus couldn't use a setter
- (void)initMenuView {
    [self.menuView addSubview:self.menuViewController.view];
}

- (void)initContentView {
    self.contentView.layer.masksToBounds = NO;
    self.contentView.layer.shadowOffset = CGSizeMake(-3, 0);
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 0.5;
}


- (void)setContentViewController:(UIViewController *)contentViewController {
    _contentViewController = contentViewController;
    [self.contentView addSubview:contentViewController.view];

    if (contentViewController) {
        [contentViewController willMoveToParentViewController:nil];
        [contentViewController.view removeFromSuperview];
        [contentViewController didMoveToParentViewController:nil];
    }

    [self.contentViewController willMoveToParentViewController:self];
    [self.contentView addSubview:contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self hideMenu];
}

# pragma mark - Guesture handler

- (IBAction)onContentPanGuesture:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.contentView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        originalContentViewLeftMargin = self.contentViewLeftMargin.constant;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        if ((self.contentViewLeftMargin.constant >= 0 && translation.x > 0) || (self.contentViewLeftMargin.constant > 0 && translation.x < 0)) {
            self.contentViewLeftMargin.constant = originalContentViewLeftMargin + translation.x;
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (translation.x > 0) {
            [self showMenu];
        }
        else {
            [self hideMenu];
        }
    }
}

# pragma mark - Menu animation

- (void)showMenu {
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.contentViewLeftMargin.constant = self.contentView.frame.size.width - 100;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)hideMenu {
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.contentViewLeftMargin.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)toggleMenu {
    if (self.contentViewLeftMargin.constant > 0) {
        [self hideMenu];
    }
    else {
        [self showMenu];
    }
}

# pragma Private method

- (void)newProfileRequest:(NSNotification *)notification {
    if (notification.userInfo[@"user_id"]) {
        self.contentViewController = [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] initWithDictionary:notification.userInfo]];

         NSLog(@"[INFO] New profile request received");
    }
}

@end
