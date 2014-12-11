//
//  WeatherlyticsGenerator.m
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCWeatherlyticsGenerator.h"
#import "WSCNetworking.h"
#import "WSCGame.h"

//WXCore
#import "WXWeatherDataService/WXWeatherDataService+Observations.h"

@interface WSCWeatherlyticsGenerator ()

@property (nonatomic, strong) NSDictionary *teamLocations;
@property (nonatomic, strong) NSArray      *games;

//For tracking progress
@property (nonatomic, assign) NSUInteger totalGames;
@property (nonatomic, assign) NSUInteger gamesAnalyzed;


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
        [self loadTeamLocations];
        
    }
    return self;
}

#pragma mark - Weatherlytics Generation

- (void)generateWeatherlyticsWithGames:(NSArray *)games {
    self.games = games;
    self.totalGames = games.count;
    self.gamesAnalyzed = 0;
    
    //Loop through all games
    for(WSCGame *game in games) {
        //Get coordinates of home team (likely the game's location)
        NSDictionary *teamData = [self.teamLocations objectForKey:game.homeTeam];
        if(teamData) {
            NSString *stadiumCoordinates = [teamData objectForKey:@"stadiumCoordinates"];
            
            __block WSCGame *blockGame = game;
            
            //Request weather on that day at location
            [self requestWeatherDataWithLocation:stadiumCoordinates andGame:blockGame];
        }
        else {
            //Subtract it from the count if we aren't going to analyze it
            self.totalGames--;
        }
    }
    
    
}

- (void)finishAnalysis {
    //Analyze all teams
    for(NSString *teamName in self.teamLocations) {
        NSPredicate *teamPredicate = [NSPredicate predicateWithFormat:@"homeTeam = %@ OR awayTeam = %@", teamName, teamName];
        NSArray *gamesInvolvingTeam = [self.games filteredArrayUsingPredicate:teamPredicate];
        
        NSLog(@"");
    }
}

#pragma mark - Team Locations

- (void)loadTeamLocations {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"teamLocations" ofType:@"json"];
    NSData *teamData = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:teamData options:0 error:&localError];
    
    self.teamLocations = parsedObject;
}

#pragma mark - Weather Data

- (void)requestWeatherDataWithLocation:(NSString *)coordinates andGame:(WSCGame *)game {
    //http://dsx.weather.com/wxd/PastObs/20131123/2/USGA0038:1:US
    
    //Build url string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *formattedDateString = [dateFormatter stringFromDate:game.date];
    
    NSString *urlString = [NSString stringWithFormat:@"http://dsx.weather.com/wxd/PastObs/%@/1/%@",formattedDateString,coordinates];
    
    __block WSCGame *blockGame = game;
    __block NSString *blockDateString = formattedDateString;
    
    [[WSCNetworking sharedInstance] sendGetRequest:urlString completionHandler:^(NSData *data) {
        NSError *localError = nil;
        if(data) {
            NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            NSDictionary *dict = parsedObject[0];
            NSDictionary *doc = [dict objectForKey:@"doc"];
            NSDictionary *pastObsData = [doc objectForKey:@"PastObsData"];
            NSDictionary *date = [pastObsData objectForKey:blockDateString];
            NSArray *dataArray = [date objectForKey:@"data"];
            NSDictionary *observation = dataArray[0];
            
            //Save weather info into game object
            blockGame.gameTemperature = [self gameTemperatureWithString:[observation objectForKey:@"tmpF"]];
            blockGame.gameCondition = [self gameConditionWithString:[observation objectForKey:@"wx"]];
            blockGame.gameHumidity = [self gameHumidityWithString:[observation objectForKey:@"rH"]];
            blockGame.gameWind = [self gameWindWithString:[observation objectForKey:@"wSpdM"]];
            blockGame.gamePressure = [self gameWindWithString:[observation objectForKey:@"alt"]];
            
        }
        
        self.gamesAnalyzed++;
        if(self.gamesAnalyzed >= self.totalGames) {
            [self finishAnalysis];
        }
    }];
    
}

#pragma mark - Quantizing Weather Parameters

- (WSCGameTemperature)gameTemperatureWithString:(NSString *)temperatureString {
    WSCGameTemperature gameTemperature;
    
    NSUInteger temperature = [temperatureString integerValue];
    if(temperature < 35) {
        gameTemperature = WSCGameTemperatureCold;
    }
    else if(temperature >= 35 && temperature < 50) {
        gameTemperature = WSCGameTemperatureCool;
    }
    else if(temperature >= 50 && temperature < 65) {
        gameTemperature = WSCGameTemperatureMild;
    }
    else if(temperature >= 65 && temperature < 80) {
        gameTemperature = WSCGameTemperatureWarm;
    }
    else {
        gameTemperature = WSCGameTemperatureHot;
    }
    
    return gameTemperature;
}

- (WSCGameCondition)gameConditionWithString:(NSString *)conditionString {
    WSCGameCondition gameCondition = WSCGameConditionSunny;
    
    NSString *condition = [conditionString lowercaseString];
    
    if([condition rangeOfString:@"cloudy"].location != NSNotFound) {
        gameCondition = WSCGameConditionCloudy;
    }
    else if([condition rangeOfString:@"sun"].location != NSNotFound) {
        gameCondition = WSCGameConditionSunny;
    }
    else if([condition rangeOfString:@"rain"].location != NSNotFound) {
        gameCondition = WSCGameConditionRain;
    }
    else if([condition rangeOfString:@"snow"].location != NSNotFound) {
        gameCondition = WSCGameConditionSnow;
    }
    else if([condition rangeOfString:@"fair"].location != NSNotFound) {
        gameCondition = WSCGameConditionFair;
    }
    else {
        NSLog(@"NEW CONDITION TYPE!");
    }
    
    return gameCondition;
}

- (WSCGameHumidity)gameHumidityWithString:(NSString *)humidityString {
    WSCGameHumidity gameHumidity;
    
    NSUInteger humidity = [humidityString integerValue];
    if(humidity < 15) {
        gameHumidity = WSCGameHumidityNone;
    }
    else if(humidity >= 15 && humidity < 40) {
        gameHumidity = WSCGameHumidityLow;
    }
    else if(humidity >= 40 && humidity < 70) {
        gameHumidity = WSCGameHumidityMedium;
    }
    else {
        gameHumidity = WSCGameHumidityHigh;
    }
    
    return gameHumidity;
}

- (WSCGameWind)gameWindWithString:(NSString *)windString {
    WSCGameWind gameWind;
    
    NSUInteger wind = [windString integerValue];
    if(wind < 5) {
        gameWind = WSCGameWindNone;
    }
    else if(wind >= 5 && wind < 12) {
        gameWind = WSCGameWindLow;
    }
    else if(wind >= 12 && wind < 20) {
        gameWind = WSCGameWindMedium;
    }
    else {
        gameWind = WSCGameWindHigh;
    }
    
    return gameWind;
}

- (WSCGamePressure)gamePressureWithString:(NSString *)pressureString {
    WSCGamePressure gamePressure;
    
    NSUInteger pressure = [pressureString doubleValue];
    if(pressure < 29.85) {
        gamePressure = WSCGamePressureLow;
    }
    else if(pressure >= 29.85 && pressure < 30.2) {
        gamePressure = WSCGamePressureMedium;
    }
    else  {
        gamePressure = WSCGamePressureHigh;
    }
    
    return gamePressure;
}

@end
