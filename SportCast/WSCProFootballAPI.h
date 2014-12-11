//
//  WSCProFootballAPI.h
//  SportCast
//
//  Created by Ross Mooney on 12/9/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCProFootballAPI : NSObject

@property (nonatomic, strong) NSArray *games;


+ (id)sharedInstance;

//API Methods
- (void)requestAllGamesWithCompletion:(void (^)(NSArray *))completion;

@end
