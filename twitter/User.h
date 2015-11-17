//
//  User.h
//  twitter
//
//  Created by Chang Liu on 11/8/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSString *tagLine;
@property (nonatomic, strong) NSString *followersCount;
@property (nonatomic, strong) NSString *followingCount;
@property (nonatomic, strong) NSString *statusesCount;
@property (nonatomic, strong) NSString *backgroundImageURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (void)getUserWithUserID:(NSString *)userID completion:(void (^)(User *user, NSError *error))completion;
+ (void)setCurrentUser:(User *)currentUser;
+ (void)logout;

@end
