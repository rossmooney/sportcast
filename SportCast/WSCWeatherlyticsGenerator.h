//
//  WeatherlyticsGenerator.h
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCWeatherlyticsGenerator : NSObject

+ (id)sharedInstance;

- (void)generateWeatherlyticsWithGames:(NSArray *)games andCompletionHandler:(void (^)(void))completion;

@end
