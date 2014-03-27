//
//  PREAPIClient.m
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PREAPIClient.h"
#import "PREUser.h"
#import "PRECreditCard.h"
#import "PREWebViewController.h"

static NSString *const kPREAPIKEY = @"";
static NSString *const kPREAPIURL = @"https://presto-api.herokuapp.com";

@implementation PREAPIClient

+ (void)getCardStatusForCurrentUserWithCompletion:(PREAPIResponseBlock)completion {
    PREUser *user = [[PREUser allInstances] lastObject];
    if (user.username.length > 0) {
        [self getCardStatusWithUsername:user.username password:user.password completion:completion];
    } else {
        [self getCardStatusWithCardNumber:user.cardNumber completion:completion];
    }
}

+ (void)getCardStatusWithUsername:(NSString *)username password:(NSString *)password completion:(PREAPIResponseBlock)completion {
    [self getPath:[NSString stringWithFormat:@"card_status/%@/%@", username, password] completionHandler:completion];
}

+ (void)getCardStatusWithCardNumber:(NSString *)cardNumber completion:(PREAPIResponseBlock)completion {
    [self getPath:[NSString stringWithFormat:@"card_status/%@", cardNumber] completionHandler:completion];
}

+ (void)getUserWithUsername:(NSString *)username password:(NSString *)password completion:(PREAPIResponseBlock)completion {
    [self getPath:[NSString stringWithFormat:@"me/%@/%@", username, password] completionHandler:completion];
}

+ (void)loadAmount:(NSString *)amount email:(NSString *)email cardNumber:(NSString *)cardNumber creditCard:(PRECreditCard *)creditCard completion:(PREAPIResponseBlock)completion {
    NSDictionary *params = @{@"credit_card_name": creditCard.name,
                             @"credit_card_number": creditCard.number,
                             @"credit_card_expiry_month": creditCard.expiryMonth,
                             @"credit_card_expiry_year": creditCard.expiryYear,
                             @"card_number": cardNumber,
                             @"email": email,
                             @"amount": amount};
    [self postPath:@"balance" params:params completionHandler:^(id responseObject, NSURLResponse *response, NSError *error) {
        NSString *html = [responseObject stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        html = [html stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
        completion(html, response, error);
    }];
}

// Example method on how to *almost* load money onto a Presto card
+ (void)loadCard {
    PRECreditCard *creditCard = [PRECreditCard instanceWithPrimaryKey:@"4242424242424242"];
    creditCard.name = @"John Doe";
    creditCard.expiryMonth = @"01";
    creditCard.expiryYear = @"20";
    [creditCard save];
    
    [PREAPIClient loadAmount:@"10.00" email:@"johndoe@example.com" cardNumber:@"XXXXXXXXXXXXXXXXX" creditCard:creditCard completion:^(id responseObject, NSURLResponse *response, NSError *error) {
        NSString *js = @"document.downloadForm.submit()";
        PREWebViewController *webVC = [PREWebViewController webVCWithHTML:responseObject
                                                               javascript:js];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:webVC];
        UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
        [window.rootViewController presentViewController:navVC animated:YES completion:nil];
    }];
}

#pragma mark - Private

#pragma mark - Singleton

+ (instancetype)sharedClient {
    static PREAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = (PREAPIClient *)[PREAPIClient sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    
    return _sharedClient;
}

#pragma mark - JSON

+ (id)objectFromResponseData:(NSData *)data error:(NSError **)error {
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (!responseObject) {
        responseObject = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return responseObject;
}

#pragma mark - Helpers

+ (NSURL *)urlWithPath:(NSString *)path {
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:kPREAPIURL]];
}

+ (NSURLRequest *)requestWithPath:(NSString *)path method:(NSString *)method {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlWithPath:path]];
    request.HTTPMethod = method;
    [request setValue:kPREAPIKEY forHTTPHeaderField:@"x-api-key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

+ (void)getPath:(NSString *)path completionHandler:(void (^)(id responseObject, NSURLResponse *response, NSError *error))completionHandler {
    [self startRequest:[self requestWithPath:path method:@"GET"] completionHandler:completionHandler];
}

+ (void)postPath:(NSString *)path params:(NSDictionary *)params completionHandler:(void (^)(id responseObject, NSURLResponse *response, NSError *error))completionHandler {
    NSMutableURLRequest *request = (NSMutableURLRequest *)[self requestWithPath:path method:@"POST"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)request.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
    
    [self startRequest:request completionHandler:completionHandler];
}

+ (void)startRequest:(NSURLRequest *)request completionHandler:(void (^)(id responseObject, NSURLResponse *response, NSError *error))completionHandler {
    [[[self sharedClient] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, response, error);
            });
        } else {
            id responseObject = [self objectFromResponseData:data error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(responseObject, response, error);
            });
        }
    }] resume];
}

@end
