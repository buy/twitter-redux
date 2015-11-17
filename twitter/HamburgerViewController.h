//
//  HamburgerViewController.h
//  twitter
//
//  Created by Chang Liu on 11/16/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HamburgerViewController : UIViewController

@property (strong, nonatomic) UIViewController *menuViewController;
@property (strong, nonatomic) UIViewController *contentViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewLeftMargin;

- (void)showMenu;
- (void)hideMenu;

@end
