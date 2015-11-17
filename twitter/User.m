//
//  User.m
//  twitter
//
//  Created by Chang Liu on 11/8/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "User.h"
#import "TwttierClient.h"

static User *_currentUser = nil;
NSString * const kCurrentUserKey = @"kCurrentUserKey";
NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User ()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.userID = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.screenName = [NSString stringWithFormat:@"@%@", dictionary[@"screen_name"]];
        self.profileImageURL = dictionary[@"profile_image_url"];
        self.tagLine = dictionary[@"tagLine"];
        self.followersCount = [NSString stringWithFormat:@"%@", dictionary[@"followers_count"]];
        self.followingCount = [NSString stringWithFormat:@"%@", dictionary[@"friends_count"]];
        self.statusesCount = [NSString stringWithFormat:@"%@", dictionary[@"statuses_count"]];
        self.backgroundImageURL = dictionary[@"profile_background_image_url_https"];
    }
    
    return self;
}

+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (_currentUser) {
        NSData *data =  [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)getUserWithUserID:(NSString *)userID
                 completion:(void (^)(User *user, NSError *error))completion{
    [[TwitterClient sharedInstance] fetchUserWithCompletion:userID completion:^(User *user, NSError *error) {
        completion(user, error);
    }];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

#pragma mark - Private methods

- (NSString *)description {
    return [NSString stringWithFormat:@"\n\tName:%@\n\tScreenName:%@\n\tProfileImageUrl:%@\n\tTagLine:%@\n\t",
            self.name,
            self.screenName,
            self.profileImageURL,
            self.tagLine];
}

@end
