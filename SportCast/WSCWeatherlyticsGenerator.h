//
//  WeatherlyticsGenerator.h
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSCGame.h"
#import "WSCWeatherlytics.h"
@interface WSCWeatherlyticsGenerator : NSObject

@property (nonatomic, strong) NSArray *leagueWeatherlytics;
+ (id)sharedInstance;

- (void)generateWeatherlyticsWithGames:(NSArray *)games andCompletionHandler:(void (^)(void))completion;
- (WSCWeatherlytics *)weatherlyticsForTeam:(NSString *)team;

- (WSCGameTemperature)gameTemperatureWithString:(NSString *)temperatureString;
- (WSCGameCondition)gameConditionWithString:(NSString *)conditionString;
- (WSCGameHumidity)gameHumidityWithString:(NSString *)humidityString;
- (WSCGameWind)gameWindWithString:(NSString *)windString;
- (WSCGamePressure)gamePressureWithString:(NSString *)pressureString;
@end
