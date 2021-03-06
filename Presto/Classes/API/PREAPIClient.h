//
//  PREAPIClient.h
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PRECreditCard;

typedef void(^PREAPIResponseBlock)(id responseObject, NSURLResponse *response, NSError *error);

@interface PREAPIClient : NSURLSession

+ (void)getCardStatusForCurrentUserWithCompletion:(PREAPIResponseBlock)completion;

+ (void)getCardStatusWithUsername:(NSString *)username password:(NSString *)password completion:(PREAPIResponseBlock)completion;

+ (void)getCardStatusWithCardNumber:(NSString *)cardNumber completion:(PREAPIResponseBlock)completion;

+ (void)getUserWithUsername:(NSString *)username password:(NSString *)password completion:(PREAPIResponseBlock)completion;

+ (void)loadAmount:(NSString *)amount email:(NSString *)email cardNumber:(NSString *)cardNumber creditCard:(PRECreditCard *)creditCard completion:(PREAPIResponseBlock)completion;

@end
