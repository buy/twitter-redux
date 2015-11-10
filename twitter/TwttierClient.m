//
//  TwitterClient.m
//  twitter
//
//  Created by Chang Liu on 11/8/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "TwttierClient.h"
#import "User.h"
#import "Tweet.h"

NSString * const kTwitterConsumerKey = @"ki3qeLbcjicnMHMBffie9y0Tf";
NSString * const kTwitterConsumerSecret = @"BmgNJzvjldyitMNZlOKe88LsQC1It1gR58bxyw3UFtML8ni0h6";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient ()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);
@property (nonatomic, strong) void (^fetchTweetsCompletion)(NSArray *tweets, NSError *error);
@property (nonatomic, strong) void (^postTweetCompletion)(Tweet *tweet, NSError *error);
@property (nonatomic, strong) void (^postLikeCompletion)(Tweet *tweet, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance; {
    static TwitterClient *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl]
                                                  consumerKey:kTwitterConsumerKey
                                               consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

#pragma mark - Service call

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"ngliutwitter://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"[INFO] Got request token %@", requestToken);
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        
        [[UIApplication sharedApplication] openURL:authURL];
    } failure:^(NSError *error) {
        NSLog(@"[ERROR] Failed getting request token %@", error);
        self.loginCompletion(nil, error);
    }];
}

- (void)fetchTweetsWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion {
    self.fetchTweetsCompletion = completion;

    [self GET:@"1.1/statuses/home_timeline.json" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        self.fetchTweetsCompletion(tweets, nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"[ERROR] Failed fetching the tweets: %@", error);
        self.fetchTweetsCompletion(nil, error);
    }];
}

- (void)postTweetWithCompletion:(NSDictionary *)dictionary
                     completion:(void (^)(Tweet *tweet, NSError *error))completion {

    self.postTweetCompletion = completion;

    [self POST:@"1.1/statuses/update.json" parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        NSLog(@"%@", tweet);
        self.postTweetCompletion(tweet, nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"[ERROR] Failed posting tweet: %@", error);
        self.postTweetCompletion(nil, error);
    }];
}

- (void)postLikeWithCompletion:(NSDictionary *)dictionary
                     completion:(void (^)(Tweet *tweet, NSError *error))completion {
    
    self.postTweetCompletion = completion;
    
    [self POST:@"1.1/favorites/create.json" parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        NSLog(@"[INFO] Successfully liked");
        self.postTweetCompletion(tweet, nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"[ERROR] Failed posting tweet: %@", error);
        self.postTweetCompletion(nil, error);
    }];
}

- (void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"[INFO] Got access token: %@", accessToken);
        [self.requestSerializer saveAccessToken:accessToken];
        [self fetchUser];
    } failure:^(NSError *error) {
        NSLog(@"[ERROR] Failed getting the access token: %@", error);
        self.loginCompletion(nil, error);
    }];
}

#pragma mark - Private methods

- (void)fetchUser {
    [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        User *user = [[User alloc] initWithDictionary:responseObject];
        [User setCurrentUser:user];
        NSLog(@"[INFO] Got user: %@", user);
        self.loginCompletion(user, nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"[ERROR] Failed getting the user: %@", error);
        self.loginCompletion(nil, error);
    }];
}

@end
