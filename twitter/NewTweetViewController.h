//
//  NewTweetViewController.h
//  twitter
//
//  Created by Chang Liu on 11/10/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

extern NSString * const TweetUpdateNofication;

@interface NewTweetViewController : UIViewController

- (instancetype)initWithDictionary:(NSDictionary *)data;

@end
