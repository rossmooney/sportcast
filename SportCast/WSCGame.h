//
//  WSCGame.h
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>

//enum {
//    WSCGameNeutral,
//    WSCGameHome,
//    WSCGameAway
//};
//typedef NSUInteger WSCGameLocation;

enum {
    WSCGameSeasonPreseason,
    WSCGameSeasonRegular,
    WSCGameSeasonPostseason
};
typedef NSUInteger WSCGameSeasonType;



enum {
    WSCGameTemperatureCold,
    WSCGameTemperatureCool,
    WSCGameTemperatureMild,
    WSCGameTemperatureWarm,
    WSCGameTemperatureHot
};
typedef NSUInteger WSCGameTemperature;

enum {
    WSCGameConditionSunny,
    WSCGameConditionCloudy,
    WSCGameConditionRain,
    WSCGameConditionSnow,
    WSCGameConditionFair,
    WSCGameConditionFog
};
typedef NSUInteger WSCGameCondition;

enum {
    WSCGameWindNone,
    WSCGameWindLow,
    WSCGameWindMedium,
    WSCGameWindHigh
};
typedef NSUInteger WSCGameWind;

enum {
    WSCGameHumidityNone,
    WSCGameHumidityLow,
    WSCGameHumidityMedium,
    WSCGameHumidityHigh
};
typedef NSUInteger WSCGameHumidity;


enum {
    WSCGamePressureLow,
    WSCGamePressureMedium,
    WSCGamePressureHigh
};
typedef NSUInteger WSCGamePressure;

enum {
    WSCGameStadiumOpen,
    WSCGameStadiumDome,
    WSCGameStadiumRetractable
};
typedef NSUInteger WSCGameStadiumType;


@interface WSCGame : NSObject

//Game Information
@property (nonatomic, assign) long               gameId;
@property (nonatomic, strong) NSDate             *date;
@property (nonatomic, strong) NSString           *homeTeam;
@property (nonatomic, strong) NSString           *awayTeam;
@property (nonatomic, strong) NSNumber           *homeScore;
@property (nonatomic, strong) NSNumber           *awayScore;
@property (nonatomic, assign) BOOL               isNightGame;
@property (nonatomic, assign) BOOL               isFinal;
@property (nonatomic, assign) WSCGameSeasonType  seasonType;
@property (nonatomic, assign) WSCGameStadiumType stadiumType;


//Weather Information
@property (nonatomic, assign) WSCGameTemperature   gameTemperature;
@property (nonatomic, assign) WSCGameCondition     gameCondition;
@property (nonatomic, assign) WSCGameHumidity      gameHumidity;
@property (nonatomic, assign) WSCGameWind          gameWind;
@property (nonatomic, assign) WSCGamePressure      gamePressure;

@end
