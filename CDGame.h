//
//  Game.h
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDGame : NSManagedObject

@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * homeTeam;
@property (nonatomic, retain) NSString * awayTeam;
@property (nonatomic, retain) NSNumber * homeScore;
@property (nonatomic, retain) NSNumber * awayScore;
@property (nonatomic, retain) NSNumber * isNightGame;
@property (nonatomic, retain) NSNumber * isFinal;
@property (nonatomic, retain) NSNumber * seasonType;
@property (nonatomic, retain) NSNumber * stadiumType;
@property (nonatomic, retain) NSNumber * gameTemperature;
@property (nonatomic, retain) NSNumber * gameCondition;
@property (nonatomic, retain) NSNumber * gameHumidity;
@property (nonatomic, retain) NSNumber * gameWind;
@property (nonatomic, retain) NSNumber * gamePressure;

@end
