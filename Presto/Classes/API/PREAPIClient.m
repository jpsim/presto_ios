//
//  PREAPIClient.m
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PREAPIClient.h"

@implementation PREAPIClient

+ (void)getCardStatusWithUsername:(NSString *)username password:(NSString *)password completion:(PREAPIResponseBlock)completion {
    [self getPath:[NSString stringWithFormat:@"card_status/%@/%@", username, password] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        } else {
            id responseObject = [self objectFromResponseData:data error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(responseObject, error);
            });
        }
    }];
}

+ (void)getCardStatusWithCardNumber:(NSString *)cardNumber completion:(PREAPIResponseBlock)completion {
    [self getPath:[NSString stringWithFormat:@"card_status/%@", cardNumber] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        } else {
            id responseObject = [self objectFromResponseData:data error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(responseObject, error);
            });
        }
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
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

#pragma mark - Helpers

+ (NSURL *)urlWithPath:(NSString *)path {
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:@"https://presto-api.herokuapp.com"]];
}

+ (void)getPath:(NSString *)path completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    [[[self sharedClient] dataTaskWithURL:[self urlWithPath:path] completionHandler:completionHandler] resume];
}

@end