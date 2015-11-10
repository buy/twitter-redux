//
//  NewTweetViewController.m
//  twitter
//
//  Created by Chang Liu on 11/10/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "NewTweetViewController.h"
#import "TwttierClient.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

NSString * const PostNewTweetNofication = @"PostNewTweetNofication";

@interface NewTweetViewController ()

@property (weak, nonatomic) IBOutlet UITextView *statusText;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) Tweet *tweet;

@end

@implementation NewTweetViewController

- (instancetype)initWithTweet:(Tweet *)tweet {
    self = [super init];

    if (self) {
        self.tweet = tweet;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.statusText becomeFirstResponder];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initNavigationHeader];
    User *user = [User currentUser];
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.profileImage.layer.cornerRadius = 5;
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = user.screenName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initializers

- (void)initNavigationHeader {
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];
}

- (void)loadUser {
    User *user = [User currentUser];

    [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = user.screenName;
}

#pragma mark - Private methods

- (void)onCancelButton {
    [self.mainView endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTweetButton {
    [self.mainView endEditing:YES];

    NSDictionary *tweetData = @{};
    
    if (self.tweet.tweetID) {
        tweetData = @{@"status": self.statusText.text, @"in_reply_to_status_id": self.tweet.tweetID};

    }
    else {
        tweetData = @{@"status": self.statusText.text};

    }

    [[TwitterClient sharedInstance] postTweetWithCompletion:tweetData completion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            NSLog(@"[INFO] New tweet posted");
            [[NSNotificationCenter defaultCenter] postNotificationName:PostNewTweetNofication object:nil userInfo:@{@"tweet": tweet}];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            NSLog(@"[ERROR] Unable to post new tweet");
        }
    }];
}

@end
