//
//  HamburgerViewController.m
//  twitter
//
//  Created by Chang Liu on 11/16/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "HamburgerViewController.h"
#import "MenuViewController.h"

@interface HamburgerViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *menuView;

@property (weak, nonatomic) UINavigationController *menuViewController;

@end

@implementation HamburgerViewController

CGFloat originalContentViewLeftMargin;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initMenuView];
    [self initContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Initializers

- (void)initMenuView {
    MenuViewController *menuViewController = [[MenuViewController alloc] init];
    menuViewController.hamburgerViewController = self;
    [self.menuView addSubview:menuViewController.view];
}

- (void)initContentView {
    self.contentView.layer.masksToBounds = NO;
    self.contentView.layer.shadowOffset = CGSizeMake(-3, 0);
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 0.5;
}

- (void) setContentViewController:(UIViewController *)contentViewController {
    _contentViewController = contentViewController;

    [self.view layoutIfNeeded];
    [self.contentView addSubview:contentViewController.view];
}

# pragma mark - Guesture handler

- (IBAction)onContentPanGuesture:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.contentView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        originalContentViewLeftMargin = self.contentViewLeftMargin.constant;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.contentViewLeftMargin.constant > 0) {
            self.contentViewLeftMargin.constant = originalContentViewLeftMargin + translation.x;
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             if (translation.x > 0) {
                                 [self showMenu];
                             }
                             else {
                                 [self hideMenu];
                             }

                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
}

# pragma mark - Private methods

- (void)showMenu {
    self.contentViewLeftMargin.constant = self.contentView.frame.size.width - 100;
}

- (void)hideMenu {
    self.contentViewLeftMargin.constant = 0;
}

@end
