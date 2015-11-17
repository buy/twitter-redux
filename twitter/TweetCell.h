//
//  TweetCell.h
//  twitter
//
//  Created by Chang Liu on 11/9/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

extern NSString * const OnNewProfileRequestNotification;

@interface TweetCell : UITableViewCell

@property (strong, nonatomic) Tweet *tweet;

@end
