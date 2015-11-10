//
//  Tweet.h
//  twitter
//
//  Created by Chang Liu on 11/8/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSNumber *tweetID;
@property (nonatomic, strong) NSString *text;
@property BOOL retweeted;
@property (nonatomic, strong) NSNumber *retweetedCount;
@property BOOL liked;
@property (nonatomic, strong) NSNumber *likedCount;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) Tweet *retweetedStatus;
@property (nonatomic, strong) User *user;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
