//
//  TwitterClient.h
//  twitter
//
//  Created by Chang Liu on 11/8/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;
- (void)openURL:(NSURL *)url;
- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)fetchTweetsWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion;

- (void)postTweetWithCompletion:(NSDictionary *)dictionary
                     completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)postLikeWithCompletion:(NSDictionary *)dictionary
                     completion:(void (^)(Tweet *tweet, NSError *error))completion;

@end
