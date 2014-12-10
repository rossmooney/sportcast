//
//  WeatherlyticsGenerator.m
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCWeatherlyticsGenerator.h"

@interface WSCWeatherlyticsGenerator ()

@property (nonatomic, strong) NSDictionary *teamLocations;

@end

@implementation WSCWeatherlyticsGenerator


#pragma mark Singleton Methods

+ (id)sharedInstance {
    static WSCWeatherlyticsGenerator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        //Load team locations from JSON file
        NSString *path = [[NSBundle mainBundle] pathForResource:@"teamLocations" ofType:@"json"];
        NSData *teamData = [[NSFileManager defaultManager] contentsAtPath:path];
        
        
    }
    return self;
}

#pragma mark - Weatherlytics Generation

- (void)generateWeatherlyticsWithGames:(NSArray *)games {
    
    
    
}

@end
