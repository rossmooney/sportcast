//
//  WeatherlyticsGenerator.m
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCWeatherlyticsGenerator.h"
#import "WSCWeatherlytics.h"
#import "WSCNetworking.h"
#import "WSCGame.h"
#import "WSCCoreDataManager.h"

@interface WSCWeatherlyticsGenerator ()


@property (nonatomic, strong) NSDictionary *teamLocations;
@property (nonatomic, strong) NSArray      *games;

//For tracking progress
@property (nonatomic, assign) NSUInteger totalGames;
@property (nonatomic, assign) NSUInteger gamesAnalyzed;
@property (nonatomic, copy) void (^completionHandler)(void);



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

#pragma mark - Accessing Weatherlytics 

- (WSCWeatherlytics *)weatherlyticsForTeam:(NSString *)team {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"team = %@", team];
    NSArray *filteredArray = [self.leagueWeatherlytics filteredArrayUsingPredicate:filter];
    if(filteredArray.count > 0) {
        WSCWeatherlytics *weatherlytics = filteredArray[0];
        return weatherlytics;
    }
    
    return nil;
}

#pragma mark - Weatherlytics Generation

- (void)generateWeatherlyticsWithGames:(NSArray *)games andCompletionHandler:(void (^)(void))completion{
    NSLog(@"generateWeatherlyticsWithGames");
    self.completionHandler = completion;
    
    //only use games that have finished
    NSPredicate *finalPredicate = [NSPredicate predicateWithFormat:@"isFinal == 1"];// AND analyzed == 0"];
    self.games = [games filteredArrayUsingPredicate:finalPredicate];

    self.totalGames = self.games.count;
    self.gamesAnalyzed = 0;
    
    //Loop through all games
    for(WSCGame *game in self.games) {
        //Get coordinates of home team (likely the game's location)
        NSDictionary *teamData = [self.teamLocations objectForKey:game.homeTeam];
        
        //Ensure we have the team's location and that game has finished
        if(teamData) {
            NSString *stadiumCoordinates = [teamData objectForKey:@"stadiumCoordinates"];
            NSString *stadiumType = [teamData objectForKey:@"stadiumType"];
            if([stadiumType isEqualToString:@"dome"]) {
                game.stadiumType = WSCGameStadiumDome;
            }
            else if([stadiumType isEqualToString:@"retractable"]) {
                game.stadiumType = WSCGameStadiumRetractable;
            }
            else {
                game.stadiumType = WSCGameStadiumOpen;
            }
            
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
    NSLog(@"finishAnalysis");
    NSMutableArray *leagueWeatherlytics = [NSMutableArray array];
    
    //Analyze all teams
    for(NSString *teamName in self.teamLocations) {
        //Create weatherlytics object
        WSCWeatherlytics *teamWeatherlytics = [[WSCWeatherlytics alloc] init];
        teamWeatherlytics.team = teamName;
        
        //Get games with this team
        NSPredicate *teamPredicate = [NSPredicate predicateWithFormat:@"homeTeam = %@ OR awayTeam = %@", teamName, teamName];
        NSArray *gamesInvolvingTeam = [self.games filteredArrayUsingPredicate:teamPredicate];
        
        //Temperature is an enum, but this is the easiest way to loop all possible values
        NSMutableArray *mutableTemperatureValues = [NSMutableArray arrayWithObjects:@-1, @-1, @-1, @-1, @-1, nil];
        NSUInteger totalTemperatureTypes = mutableTemperatureValues.count;
        for(int i = 0; i < totalTemperatureTypes; i++) {
            //Get all games that occurred at this temperature
            NSPredicate *temperaturePredicate = [NSPredicate predicateWithFormat:@"gameTemperature = %d", i];
            NSArray *gamesAtThisTemperature = [gamesInvolvingTeam filteredArrayUsingPredicate:temperaturePredicate];
            
            //Get win pct of these games
            if(gamesAtThisTemperature.count > 0) {
                double winPercentage = [self winPercentageForTeam:teamName withGames:gamesAtThisTemperature];
                [mutableTemperatureValues setObject:@(winPercentage) atIndexedSubscript:i];
            }
            else {
                [mutableTemperatureValues setObject:@(-1) atIndexedSubscript:i];
            }
        }
        teamWeatherlytics.temperatureValues = mutableTemperatureValues;

        NSMutableArray *mutableConditionValues = [NSMutableArray arrayWithObjects:@-1, @-1, @-1, @-1, @-1, @-1, nil];
        NSUInteger totalConditionTypes = mutableConditionValues.count;
        for(int i = 0; i < totalConditionTypes; i++) {
            //Get all games that occurred at this condition
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameCondition = %d", i];
            NSArray *gamesAtThisCondition = [gamesInvolvingTeam filteredArrayUsingPredicate:predicate];
            
            //Get win pct of these games
            if(gamesAtThisCondition.count > 0) {
                double winPercentage = [self winPercentageForTeam:teamName withGames:gamesAtThisCondition];
                [mutableConditionValues setObject:@(winPercentage) atIndexedSubscript:i];
            }
            else {
                [mutableConditionValues setObject:@(-1) atIndexedSubscript:i];
            }
        }
        teamWeatherlytics.conditionValues = mutableConditionValues;

        NSMutableArray *mutableWindValues = [NSMutableArray arrayWithObjects:@-1, @-1, @-1, @-1, nil];
        NSUInteger totalWindTypes = mutableWindValues.count;
        for(int i = 0; i < totalWindTypes; i++) {
            //Get all games that occurred at this wind speed
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameWind = %d", i];
            NSArray *gamesAtThisWindSpeed = [gamesInvolvingTeam filteredArrayUsingPredicate:predicate];
            
            //Get win pct of these games
            if(gamesAtThisWindSpeed.count > 0) {
                double winPercentage = [self winPercentageForTeam:teamName withGames:gamesAtThisWindSpeed];
                [mutableWindValues setObject:@(winPercentage) atIndexedSubscript:i];
            }
            else {
                [mutableWindValues setObject:@(-1) atIndexedSubscript:i];
            }
        }
        teamWeatherlytics.windValues = mutableWindValues;
        
        NSMutableArray *mutableHumidityValues = [NSMutableArray arrayWithObjects:@-1, @-1, @-1, @-1, nil];
        NSUInteger totalHumidityTypes = mutableHumidityValues.count;
        for(int i = 0; i < totalHumidityTypes; i++) {
            //Get all games that occurred at this condition
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameHumidity = %d", i];
            NSArray *gamesAtThisHumidity = [gamesInvolvingTeam filteredArrayUsingPredicate:predicate];
            
            //Get win pct of these games
            if(gamesAtThisHumidity.count > 0) {
                double winPercentage = [self winPercentageForTeam:teamName withGames:gamesAtThisHumidity];
                [mutableHumidityValues setObject:@(winPercentage) atIndexedSubscript:i];
            }
            else {
                [mutableHumidityValues setObject:@(-1) atIndexedSubscript:i];
            }
        }
        teamWeatherlytics.humidityValues = mutableHumidityValues;

        NSMutableArray *mutablePressureValues = [NSMutableArray arrayWithObjects:@-1, @-1, @-1, nil];
        NSUInteger totalPressureTypes = mutablePressureValues.count;
        for(int i = 0; i < totalPressureTypes; i++) {
            //Get all games that occurred at this condition
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gamePressure = %d", i];
            NSArray *gamesAtThisPressure = [gamesInvolvingTeam filteredArrayUsingPredicate:predicate];
            
            //Get win pct of these games
            if(gamesAtThisPressure.count > 0) {
                double winPercentage = [self winPercentageForTeam:teamName withGames:gamesAtThisPressure];
                [mutablePressureValues setObject:@(winPercentage) atIndexedSubscript:i];
            }
            else {
                [mutablePressureValues setObject:@(-1) atIndexedSubscript:i];
            }
        }
        teamWeatherlytics.pressureValues = mutablePressureValues;

        
        NSMutableArray *mutableStadiumTypeValues = [NSMutableArray arrayWithObjects:@-1, @-1, @-1, nil];
        NSUInteger totalStadiumTypes = mutableStadiumTypeValues.count;
        for(int i = 0; i < totalStadiumTypes; i++) {
            //Get all games that occurred at this stadium type
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stadiumType = %d", i];
            NSArray *gamesAtThisStadiumType = [gamesInvolvingTeam filteredArrayUsingPredicate:predicate];
            
            //Get win pct of these games
            if(gamesAtThisStadiumType.count > 0) {
                double winPercentage = [self winPercentageForTeam:teamName withGames:gamesAtThisStadiumType];
                [mutableStadiumTypeValues setObject:@(winPercentage) atIndexedSubscript:i];
            }
            else {
                [mutableStadiumTypeValues setObject:@(-1) atIndexedSubscript:i];
            }
        }
        teamWeatherlytics.stadiumTypeValues = mutableStadiumTypeValues;
        
        
        [leagueWeatherlytics addObject:teamWeatherlytics];
    }
    
    //Save all games
    [[WSCCoreDataManager sharedInstance] saveGames:self.games];
    
    //Save all weatherlytics
    self.leagueWeatherlytics = leagueWeatherlytics;
    [[WSCCoreDataManager sharedInstance] saveWeatherlytics:leagueWeatherlytics];
    
    //Return array of all weatherlytics for teams
    if(self.completionHandler) {
        NSLog(@"analysisComplete");
        self.completionHandler();
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
    NSLog(@"requestingWeatherData with coordinates:%@", coordinates);
    
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
            blockGame.gamePressure = [self gamePressureWithString:[observation objectForKey:@"alt"]];
            
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
    else if(([condition rangeOfString:@"rain"].location != NSNotFound)||([condition rangeOfString:@"storm"].location != NSNotFound)) {
        gameCondition = WSCGameConditionRain;
    }
    else if([condition rangeOfString:@"snow"].location != NSNotFound) {
        gameCondition = WSCGameConditionSnow;
    }
    else if(([condition rangeOfString:@"fair"].location != NSNotFound)||([condition rangeOfString:@"clear"].location != NSNotFound)) {
        gameCondition = WSCGameConditionFair;
    }
    else if([condition rangeOfString:@"fog"].location != NSNotFound) {
        gameCondition = WSCGameConditionFog;
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
    
    double pressure = [pressureString doubleValue];
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

#pragma mark - Win Percentage

- (double)winPercentageForTeam:(NSString *)team withGames:(NSArray *)games {
    //get wins
    NSPredicate *winHomePredicate = [NSPredicate predicateWithFormat:@"homeTeam = %@ AND homeScore > awayScore", team];
    NSPredicate *winAwayPredicate = [NSPredicate predicateWithFormat:@"awayTeam = %@ AND awayScore > homeScore", team];
    NSCompoundPredicate *winPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:@[winHomePredicate, winAwayPredicate]];
    
    NSArray *wins = [games filteredArrayUsingPredicate:winPredicate];
    
    //get losses
    NSPredicate *lossHomePredicate = [NSPredicate predicateWithFormat:@"homeTeam = %@ AND homeScore < awayScore", team];
    NSPredicate *lossAwayPredicate = [NSPredicate predicateWithFormat:@"awayTeam = %@ AND awayScore < homeScore", team];
    NSCompoundPredicate *lossPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:@[lossHomePredicate, lossAwayPredicate]];
    NSArray *losses = [games filteredArrayUsingPredicate:lossPredicate];
    
    //count ties as 1/2
    NSPredicate *tiePredicate = [NSPredicate predicateWithFormat:@"homeScore = awayScore"];
    NSArray *ties = [games filteredArrayUsingPredicate:tiePredicate];
    
    
    //calculate win percentage
    double winPercentage = (wins.count + ties.count * 0.5) / (wins.count + losses.count + ties.count);
    NSLog(@"winpercentage for team %@ = %f", team, winPercentage);
    return winPercentage;
}
@end
