//
//  TweetDetailViewController.m
//  twitter
//
//  Created by Chang Liu on 11/10/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "NewTweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TwttierClient.h"

@interface TweetDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *retweetImage;
@property (weak, nonatomic) IBOutlet UIButton *likeImage;
@property (weak, nonatomic) IBOutlet UIButton *replyImage;

@property (weak, nonatomic) Tweet *tweet;

- (IBAction)onRetweetButtonTouch:(id)sender;
- (IBAction)onLikeButtonTouch:(id)sender;
- (IBAction)onReplyButtonTouch:(id)sender;

@end

@implementation TweetDetailViewController

- (instancetype)initWithTweet:(Tweet *)tweet {
    self = [super init];

    if (self) {
        self.tweet = tweet;
    }
    
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initNavigationHeader];
    [self initViewWithTweet:self.tweet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initializers

- (void)initViewWithTweet:(Tweet *)tweet {
    if (self.tweet.retweetedStatus) {
        tweet = tweet.retweetedStatus;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@ Retweeted", tweet.user.name];
        self.retweetedLabel.hidden = NO;
        self.retweetedImage.hidden = NO;
    }
    else {
        self.retweetedLabel.hidden = YES;
        self.retweetedImage.hidden = YES;
    }
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImageURL]];
    self.profileImage.layer.cornerRadius = 5;
    self.nameLabel.text = tweet.user.name;
    self.screenNameLabel.text = tweet.user.screenName;
    self.tweetTextLabel.text = tweet.text;
    self.createdAtLabel.text = tweet.createdAt;
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", tweet.retweetedCount];
    self.retweetCountLabel.hidden = [tweet.retweetedCount intValue] == 0;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", tweet.likedCount];
    self.likeCountLabel.hidden = [tweet.likedCount intValue] == 0;
    
    if (self.tweet.user.userID == [User currentUser].userID) {
        [self.retweetImage setImage:[UIImage imageNamed:@"RetweetUnavailable"] forState:UIControlStateNormal];
        [self.retweetImage setEnabled:NO];
    }
    else {
        [self.retweetImage setEnabled:YES];
        if (self.tweet.retweeted) {
            [self.retweetImage setImage:[UIImage imageNamed:@"RetweetOn"] forState:UIControlStateNormal];
            self.retweetCountLabel.textColor = [UIColor colorWithRed:0.10 green:0.81 blue:0.53 alpha:1.0];
        }
        else {
            [self.retweetImage setImage:[UIImage imageNamed:@"Retweet"] forState:UIControlStateNormal];
            self.retweetCountLabel.textColor = [UIColor colorWithRed:0.67 green:0.72 blue:0.76 alpha:1.0];
        }
    }
    
    if (self.tweet.liked) {
        [self.likeImage setImage:[UIImage imageNamed:@"LikeOn"] forState:UIControlStateNormal];
        self.likeCountLabel.textColor = [UIColor colorWithRed:0.91 green:0.11 blue:0.31 alpha:1.0];
    }
    else {
        [self.likeImage setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
        self.likeCountLabel.textColor = [UIColor colorWithRed:0.67 green:0.72 blue:0.76 alpha:1.0];
    }
}

- (void)initNavigationHeader {
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReply)];
}

- (void)initNewTweetView:(NSDictionary *)data {
    NewTweetViewController *newTweetViewController = [[NewTweetViewController alloc] initWithDictionary:data];
    
    UINavigationController *newTweetNavigationController = [[UINavigationController alloc] initWithRootViewController:newTweetViewController];
    [self presentViewController:newTweetNavigationController animated:YES completion:nil];
}

#pragma mark - Event handler

- (void)onBackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onReply {
    [self initNewTweetView:@{@"tweet": self.tweet, @"replyTo": self.tweet.user.screenName}];
}

- (void)onRetweet {
    NSDictionary *tweetData = @{@"id": self.tweet.tweetID};

    if (self.tweet.retweeted) {
        [[TwitterClient sharedInstance] destroyRetweetWithCompletion:tweetData completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                NSLog(@"[INFO] Retweet removed");
                self.tweet.retweeted = NO;
                self.tweet.retweetedCount = [NSNumber numberWithInt:[self.tweet.retweetedCount intValue] - 1];
                [self viewDidLoad];
                [[NSNotificationCenter defaultCenter] postNotificationName:TweetUpdateNofication object:nil];
            }
            else {
                NSLog(@"[ERROR] Unable to remove retweet");
            }
        }];
    }
    else {
        [[TwitterClient sharedInstance] postRetweetWithCompletion:tweetData completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                NSLog(@"[INFO] Retweeted");
                self.tweet.retweeted = YES;
                self.tweet.retweetedCount = [NSNumber numberWithInt:[self.tweet.retweetedCount intValue] + 1];
                [self viewDidLoad];
                [[NSNotificationCenter defaultCenter] postNotificationName:TweetUpdateNofication object:nil];
            }
            else {
                NSLog(@"[ERROR] Unable to retweet");
            }
        }];
    }
}

- (void)onLike {
    NSDictionary *tweetData = @{@"id": self.tweet.tweetID};

    if (self.tweet.liked) {
        [[TwitterClient sharedInstance] destroyLikeWithCompletion:tweetData completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                NSLog(@"[INFO] Tweet unliked");
                self.tweet.liked = NO;
                self.tweet.likedCount = [NSNumber numberWithInt:[self.tweet.likedCount intValue] - 1];
                [self viewDidLoad];
                [[NSNotificationCenter defaultCenter] postNotificationName:TweetUpdateNofication object:nil];
            }
            else {
                NSLog(@"[ERROR] Unable to post new tweet");
            }
        }];
    }
    else {
        [[TwitterClient sharedInstance] postLikeWithCompletion:tweetData completion:^(Tweet *tweet, NSError *error) {
            if (tweet) {
                NSLog(@"[INFO] Tweet liked");
                self.tweet.liked = YES;
                self.tweet.likedCount = [NSNumber numberWithInt:[self.tweet.likedCount intValue] + 1];
                [self viewDidLoad];
                [[NSNotificationCenter defaultCenter] postNotificationName:TweetUpdateNofication object:nil];
            }
            else {
                NSLog(@"[ERROR] Unable to post new tweet");
            }
        }];
    }
}

- (IBAction)onRetweetButtonTouch:(id)sender {
    [self onRetweet];
}

- (IBAction)onLikeButtonTouch:(id)sender {
    [self onLike];
}

- (IBAction)onReplyButtonTouch:(id)sender {
    [self onReply];
}

@end
