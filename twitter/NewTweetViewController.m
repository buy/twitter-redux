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

NSString * const TweetUpdateNofication = @"PostNewTweetNofication";

@interface NewTweetViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *statusText;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *replyImage;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTextCount;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;

@property (weak, nonatomic) Tweet *tweet;
@property (weak, nonatomic) NSString *replyTo;

- (IBAction)onBottomTweetButton:(id)sender;

@end

@implementation NewTweetViewController

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];

    if (self) {
        self.tweet = data[@"tweet"];
        self.replyTo = data[@"replyTo"];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.statusText becomeFirstResponder];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initNavigationHeader];
    [self loadUser];

    if (self.replyTo) {
        self.replyImage.hidden = NO;
        self.replyLabel.hidden = NO;
        self.replyLabel.text = [NSString stringWithFormat:@"Reply to %@", self.replyTo ];
    }
    else {
        self.replyImage.hidden = YES;
        self.replyLabel.hidden = YES;
    }

    self.statusText.delegate = self;
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
}

- (void)loadUser {
    User *user = [User currentUser];

    [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.profileImage.layer.cornerRadius = 5;
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = user.screenName;
}

#pragma mark - Event handler

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
            [[NSNotificationCenter defaultCenter] postNotificationName:TweetUpdateNofication object:nil userInfo:@{@"tweet": tweet}];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            NSLog(@"[ERROR] Unable to post new tweet");
        }
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    int statusTextLength = (int)self.statusText.text.length;
    self.statusTextCount.text = [NSString stringWithFormat:@"%d", 140 - statusTextLength];

    if (statusTextLength > 140) {
        self.statusTextCount.textColor = [UIColor redColor];
        [self.tweetButton setEnabled:NO];
    }
    else {
        self.statusTextCount.textColor = [UIColor colorWithRed:0.67 green:0.72 blue:0.76 alpha:1.0];
        [self.tweetButton setEnabled:YES];
    }
}

- (IBAction)onBottomTweetButton:(id)sender {
    [self onTweetButton];
}
@end
