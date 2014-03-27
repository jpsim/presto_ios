//
//  PREUser.h
//  Presto
//
//  Created by JP Simard on 2014-03-26.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "FCModel.h"
#import "PRECard.h"

@interface PREUser : FCModel

// database columns
@property (nonatomic, copy) NSString *cardNumber;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *address1;
@property (nonatomic, copy) NSString *address2;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *postalCode;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *securityQuestion;
@property (nonatomic, copy) NSString *securityAnswer;
@property (nonatomic) NSDate *createdTime;
@property (nonatomic) NSDate *modifiedTime;

// non-columns
@property (nonatomic, readonly) PRECard *card;

- (void)updateWithAPIResponseDict:(NSDictionary *)dict;

+ (void)saveNewUserWithUsername:(NSString *)username password:(NSString *)password card:(PRECard *)card;

@end
