//
//  WSCNetworking.m
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCNetworking.h"

@implementation WSCNetworking

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static WSCNetworking *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Networking

- (void)sendPostRequest:(NSString *)url withParameters:(NSDictionary *)parameters completionHandler:(void (^)(NSData *))completionHandler {
    NSString *post = @"";
    
    //Add parameters to post string
    for(NSString *key in parameters) {
        post = [NSString stringWithFormat:@"%@&%@=%@", post, key, [parameters objectForKey:key]];
    }
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        completionHandler(data);
    }];
}

- (void)sendGetRequest:(NSString *)url completionHandler:(void (^)(NSData *))completionHandler {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        completionHandler(data);
    }];
}


@end
