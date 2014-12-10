//
//  WSCProFootballAPI.m
//  SportCast
//
//  Created by Ross Mooney on 12/9/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCProFootballAPI.h"

//API Constants
NSString * const apiKey =        @"Dz4AgiXSEoNCJHc3r7eF8y6hPsW0taVu";
NSString * const apiUrl =        @"https://profootballapi.com/";
NSString * const apiSchedule =   @"schedule";
NSString * const apiGames =      @"games";


@implementation WSCProFootballAPI

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static WSCProFootballAPI *sharedInstance = nil;
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

#pragma mark - API Methods

- (NSArray *)requestAllGames {
    NSArray *returnData;
    
    [self sendAPIPostRequest:apiSchedule withParameters:@{}];
    
    return returnData;
}


#pragma mark - Networking

- (void)sendAPIPostRequest:(NSString *)command withParameters:(NSDictionary *)parameters {
    //Set API key (to access data)
    NSString *post = [NSString stringWithFormat:@"api_key=%@", apiKey];
    
    //Add parameters to post string
    for(NSString *key in parameters) {
        post = [NSString stringWithFormat:@"%@&%@=%@", post, key, [parameters objectForKey:key]];
    }
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", apiUrl, command]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(dataString);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}
@end
