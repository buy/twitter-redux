//
//  HomeTimelineViewController.h
//  twitter
//
//  Created by Chang Liu on 11/9/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const OnMenuButtonNotification;

@interface HomeTimelineViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *homelineTableView;

- (instancetype)initWithDictionary:(NSDictionary *)data;

@end
