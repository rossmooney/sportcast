//
//  WSCNetworking.h
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCNetworking : NSObject

+ (id)sharedInstance;

- (void)sendPostRequest:(NSString *)url withParameters:(NSDictionary *)parameters completionHandler:(void (^)(NSData *))completionHandler;
- (void)sendGetRequest:(NSString *)url completionHandler:(void (^)(NSData *))completionHandler;

@end
