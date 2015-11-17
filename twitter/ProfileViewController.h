//
//  ProfileViewController.h
//  twitter
//
//  Created by Chang Liu on 11/16/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) UIViewController *hamburgerViewController;

- (instancetype)initWithDictionary:(NSDictionary *)data;

@end
