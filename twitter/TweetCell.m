//
//  TweetCell.m
//  twitter
//
//  Created by Chang Liu on 11/9/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"
#import "UIImageView+AFNetworking.h"

@interface TweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImage;
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;

@end

@implementation TweetCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;

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

    if (self.tweet.retweeted) {
        self.retweetImage.image = [UIImage imageNamed:@"RetweetOn"];
    }
    else {
        self.retweetImage.image = [UIImage imageNamed:@"Retweet"];
    }

    if (self.tweet.liked) {
        self.likeImage.image = [UIImage imageNamed:@"LikeOn"];
    }
    else {
        self.likeImage.image = [UIImage imageNamed:@"Like"];
    }
}

#pragma mark - Initializers

- (void)initStyle {
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    [self.nameLabel sizeToFit];
    self.screenNameLabel.preferredMaxLayoutWidth = self.screenNameLabel.frame.size.width;
    [self.screenNameLabel sizeToFit];
    self.tweetTextLabel.preferredMaxLayoutWidth = self.tweetTextLabel.frame.size.width;
    self.tweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tweetTextLabel.numberOfLines = 0;
    [self.tweetTextLabel sizeToFit];
}

@end
