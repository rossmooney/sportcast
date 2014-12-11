//
//  WSCProFootballAPI.m
//  SportCast
//
//  Created by Ross Mooney on 12/9/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCProFootballAPI.h"
#import "WSCNetworking.h"
#import "WSCGame.h"
#import "NSDate+NoTime.h"

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

- (void)requestUpcomingGamesForDays:(NSUInteger)days withCompletion:(void (^)(NSArray *))completion {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];

    
    [[WSCNetworking sharedInstance] sendPostRequest:[NSString stringWithFormat:@"%@%@", apiUrl, apiSchedule] withParameters:@{@"api_key":apiKey, @"year":[NSString stringWithFormat:@"%d",components.year], @"month":[NSString stringWithFormat:@"%d",components.month]} completionHandler:^(NSData *data) {
        NSArray *games = [self gamesFromJSON:data error:nil];
        
        NSMutableArray *mutableGames = [NSMutableArray array];
        NSDate *daysAgo = [[NSDate date] dateByAddingTimeInterval:(3600*24*days)];
        for(WSCGame *game in games) {
        
            if(([[game.date dateWithoutTime] compare:daysAgo] == NSOrderedAscending)&&([[game.date dateWithoutTime] compare:[NSDate date]] == NSOrderedDescending)){
                [mutableGames addObject:game];
            }
        }
        
        completion(mutableGames);
    }];
}

- (void)requestAllGamesWithCompletion:(void (^)(NSArray *))completion;
 {
    [[WSCNetworking sharedInstance] sendPostRequest:[NSString stringWithFormat:@"%@%@", apiUrl, apiSchedule] withParameters:@{@"api_key":apiKey, @"year":@"2014"} completionHandler:^(NSData *data) {
        NSArray *games = [self gamesFromJSON:data error:nil];
        
        //Only add new games
        NSMutableArray *workingGames = [NSMutableArray array];
        for(WSCGame *game in games) {
            NSPredicate *filter = [NSPredicate predicateWithFormat:@"gameId = %ld", game.gameId];
            NSArray *thisGame = [self.games filteredArrayUsingPredicate:filter];
            if(thisGame.count > 0) {
                [workingGames addObject:thisGame[0]];
            }
            else {
                [workingGames addObject:game];
            }
        }
        
        self.games = workingGames;
        
        completion(self.games);
    }];

}

- (NSArray *)gamesFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *games = [[NSMutableArray alloc] init];

    for (NSDictionary *gameDict in parsedObject) {
        WSCGame *game = [[WSCGame alloc] init];
        game.gameId =  [[gameDict objectForKey:@"id"] longValue];
        game.homeTeam = [gameDict objectForKey:@"home"];
        game.awayTeam = [gameDict objectForKey:@"away"];
        game.homeScore = @([[gameDict objectForKey:@"home_score"] integerValue]);
        game.awayScore = @([[gameDict objectForKey:@"away_score"] integerValue]);
        NSNumber *finalNumber = [gameDict objectForKey:@"final"] ;
        if([finalNumber integerValue] == 1) {
            game.isFinal = YES;
        }
        else {
            game.isFinal = NO;
        }
        //Get the game start time and convert to GMT (for easy comparison)
        NSDate *gameTime = [NSDate dateWithTimeIntervalSince1970:[[gameDict objectForKey:@"time"] integerValue]];
        NSTimeZone *tz = [NSTimeZone localTimeZone];
        NSInteger seconds = -[tz secondsFromGMTForDate: gameTime];
        gameTime = [NSDate dateWithTimeInterval: seconds sinceDate: gameTime];
        game.date = gameTime;
        game.isNightGame = [self isNightTime:game.date];

        NSString *seasonType = [gameDict objectForKey:@"season_type"];
        if([seasonType isEqualToString:@"PRE"]) {
            game.seasonType = WSCGameSeasonPreseason;
        }
        else if([seasonType isEqualToString:@"REG"]) {
            game.seasonType = WSCGameSeasonRegular;
        }
        else {
            game.seasonType = WSCGameSeasonPostseason;
        }
        [games addObject:game];
    }
    
    return games;
}

- (BOOL)isNightTime:(NSDate *)date {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitHour
                                                         fromDate:date];
    if(components.hour > 18) {
        return YES;
    }
    return NO;
}
@end
