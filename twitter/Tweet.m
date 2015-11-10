//
//  Tweet.m
//  twitter
//
//  Created by Chang Liu on 11/8/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "Tweet.h"
#import "User.h"
#import "NSDate+RelativeTime.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.tweetID = dictionary[@"id"];
        self.text = dictionary[@"text"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [[formatter dateFromString:dictionary[@"created_at"]] relativeTime];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.retweeted = [dictionary[@"retweeted"] integerValue] == 1;
        self.retweetedCount = dictionary[@"retweet_count"];
        self.liked = [dictionary[@"favorited"] integerValue] == 1;
        self.likedCount = dictionary[@"favorite_count"];

        if (dictionary[@"retweeted_status"]) {
            self.retweetedStatus = [[Tweet alloc] initWithDictionary:dictionary[@"retweeted_status"]];
            self.retweetedStatus.user = [[User alloc] initWithDictionary:dictionary[@"retweeted_status"][@"user"]];
        }
    }

    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

#pragma mark - Private methods

- (NSString *)description {
    return [NSString stringWithFormat:@"\n\tTweet:%@\n\tCreatedAt:%@\n\tUser: -%@\n\t",
            self.text,
            self.createdAt,
            self.user];
}

@end
