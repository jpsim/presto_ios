//
//  PREUser.m
//  Presto
//
//  Created by JP Simard on 2014-03-26.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PREUser.h"

@implementation PREUser

- (BOOL)shouldInsert {
    self.createdTime = [NSDate date];
    self.modifiedTime = self.createdTime;
    return YES;
}

- (BOOL)shouldUpdate {
    self.modifiedTime = [NSDate date];
    return YES;
}

- (PRECard *)card {
    return [PRECard instanceWithPrimaryKey:self.cardNumber];
}

#pragma mark - Description

- (NSString *)description {
    NSArray *properties = @[@"cardNumber",
                            @"username",
                            @"password",
                            @"firstName",
                            @"lastName",
                            @"address1",
                            @"address2",
                            @"city",
                            @"province",
                            @"country",
                            @"postalCode",
                            @"phoneNumber",
                            @"email",
                            @"securityQuestion",
                            @"securityAnswer",
                            @"createdTime",
                            @"modifiedTime"];
    NSMutableString *description = @"".mutableCopy;
    for (NSString *property in properties) {
        [description appendFormat:@"%@: %@\n", property, [self valueForKeyPath:property]];
    }
    // Delete last newline
    [description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
    return description;
}

#pragma mark - Updating

- (void)updateWithAPIResponseDict:(NSDictionary *)dict {
    self.firstName = dict[@"first_name"];
    self.lastName = dict[@"last_name"];
    self.address1 = dict[@"address1"];
    self.address2 = dict[@"address2"];
    self.city = dict[@"city"];
    self.province = dict[@"province"];
    self.country = dict[@"country"];
    self.postalCode = dict[@"postal_code"];
    self.phoneNumber = dict[@"phone_number"];
    self.email = dict[@"email"];
    self.securityQuestion = dict[@"security_question"];
    self.securityAnswer = dict[@"security_answer"];
}

#pragma mark - Saving

+ (void)saveNewUserWithUsername:(NSString *)username password:(NSString *)password card:(PRECard *)card {
    PREUser *user = [PREUser instanceWithPrimaryKey:card.number];
    user.username = username ?: @"";
    user.password = password ?: @"";
    [user save];
}

@end
