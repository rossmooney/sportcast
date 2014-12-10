//
//  WSCProFootballAPI.m
//  SportCast
//
//  Created by Ross Mooney on 12/9/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCProFootballAPI.h"
#import "WSCGame.h"

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
    NSData *data = [self sendAPIPostRequest:apiSchedule withParameters:@{}];
    NSArray *games = [self gamesFromJSON:data error:nil];
    
    return games;
}


#pragma mark - Networking

- (NSData *)sendAPIPostRequest:(NSString *)command withParameters:(NSDictionary *)parameters {
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
    
    return data;
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
        game.homeTeam = [gameDict objectForKey:@"home"];
        game.awayTeam = [gameDict objectForKey:@"away"];
        game.homeScore = @([[gameDict objectForKey:@"home_score"] integerValue]);
        game.awayScore = @([[gameDict objectForKey:@"away_score"] integerValue]);
        
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
