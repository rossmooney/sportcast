//
//  GameCell.m
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "GameCell.h"
#import "WeatherStatCell.h"
#import "WSCGame.h"
#import "WSCWeatherlytics.h"
#import "WSCWeatherlyticsGenerator.h"

typedef enum : NSUInteger {
    WSCWeatherStatCondition,
    WSCWeatherStatTemperature,
    WscWeatherStatWind,
    WSCWeatherStatPressure,
    WSCWeatherStatHumidity
} WSCWeatherStatEnum;

@interface GameCell () <UICollectionViewDataSource, UICollectionViewDelegate>


@property (nonatomic, strong) NSMutableArray *awayTeamStats;
@property (nonatomic, strong) NSMutableArray *homeTeamStats;

@end

@implementation GameCell

- (void)awakeFromNib {
    // Initialization code
 
    self.awayTeamStats = [NSMutableArray array];
    for(int i = 0; i < 5; i++) {
        [self.awayTeamStats addObject:@(-2)];
    }
    
    self.homeTeamStats = [NSMutableArray array];
    for(int i = 0; i < 5; i++) {
        [self.homeTeamStats addObject:@(-2)];
    }
    

}

- (void)setGame:(WSCGame *)game {
    _game = game;
    [self loadWeatherlyticsForThisWeather];
    
    [self.homeCollectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Collection View Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView == self.awayCollectionView) {
        return self.awayTeamStats.count;
    }
    else {
        return self.homeTeamStats.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    WeatherStatCell *cell;
    
    NSUInteger value;
    switch (indexPath.row) {
        case WSCWeatherStatCondition:
            value = self.game.gameCondition;
            break;
        case WSCWeatherStatTemperature:
            value = self.game.gameTemperature;
            break;
        case WSCWeatherStatPressure:
            value = self.game.gamePressure;
            break;
        case WscWeatherStatWind:
            value = self.game.gameWind;
            break;
        case WSCWeatherStatHumidity:
            value = self.game.gameHumidity;
            break;
            
        default:
            break;
    }
    
    if(collectionView == self.awayCollectionView) {
        identifier = @"AwayWeatherStatCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.winPercentage.text = [self formatWinPercentage:self.awayTeamStats[indexPath.row] ];
        cell.statPhrase.text = [self statPhraseForRow:indexPath.row withValue:value];
    }
    else {
        identifier = @"HomeWeatherStatCell";
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.winPercentage.text = [self formatWinPercentage:self.homeTeamStats[indexPath.row]];
        cell.statPhrase.text = [self statPhraseForRow:indexPath.row withValue:value];
    }
    
    return cell;

}

- (void)loadWeatherlyticsForThisWeather {
    WSCWeatherlytics *homeWeatherlytics = [[WSCWeatherlyticsGenerator sharedInstance] weatherlyticsForTeam:self.game.homeTeam];
    WSCWeatherlytics *awayWeatherlytics = [[WSCWeatherlyticsGenerator sharedInstance] weatherlyticsForTeam:self.game.awayTeam];
    
    NSString *homeTemperature = [homeWeatherlytics.temperatureValues[self.game.gameTemperature] stringValue];
    NSString *homeWind = [homeWeatherlytics.windValues[self.game.gameWind] stringValue];
    NSString *homeCondition = [homeWeatherlytics.conditionValues[self.game.gameCondition] stringValue];
    NSString *homePressure = [homeWeatherlytics.pressureValues[self.game.gamePressure] stringValue];
    NSString *homeHumidity = [homeWeatherlytics.humidityValues[self.game.gameHumidity] stringValue];
    
    if(homeTemperature) {
        self.homeTeamStats[WSCWeatherStatTemperature] = homeTemperature;
    }
    if(homePressure) {
        self.homeTeamStats[WSCWeatherStatPressure] = homePressure;
    }
    if(homeCondition) {
        self.homeTeamStats[WSCWeatherStatCondition] = homeCondition;
    }
    if(homeHumidity) {
        self.homeTeamStats[WSCWeatherStatHumidity] = homeHumidity;
    }
    if(homeWind) {
        self.homeTeamStats[WscWeatherStatWind] = homeWind;
    }
    
    
    NSString *awayTemperature = [awayWeatherlytics.temperatureValues[self.game.gameTemperature] stringValue];
    NSString *awayWind = [awayWeatherlytics.windValues[self.game.gameWind] stringValue];
    NSString *awayCondition = [awayWeatherlytics.conditionValues[self.game.gameCondition] stringValue];
    NSString *awayPressure = [awayWeatherlytics.pressureValues[self.game.gamePressure] stringValue];
    NSString *awayHumidity = [awayWeatherlytics.humidityValues[self.game.gameHumidity] stringValue];
    
    if(awayTemperature) {
        self.awayTeamStats[WSCWeatherStatTemperature] = awayTemperature;
    }
    if(awayPressure) {
        self.awayTeamStats[WSCWeatherStatPressure] = awayPressure;
    }
    if(awayCondition) {
        self.awayTeamStats[WSCWeatherStatCondition] = awayCondition;
    }
    if(awayHumidity) {
        self.awayTeamStats[WSCWeatherStatHumidity] = awayHumidity;
    }
    if(awayWind) {
        self.awayTeamStats[WscWeatherStatWind] = awayWind;
    }
}


- (NSString *)formatWinPercentage:(NSString *)winString {
    float winPercentage = [winString floatValue];
    int converted = winPercentage * 100;
    if(converted < 0){
        return @"N/A";
    }
    return [NSString stringWithFormat:@"%d%%", converted];
}

- (NSString *)statPhraseForRow:(NSInteger)row withValue:(NSUInteger)value {
    NSString *statPhrase;
    if(row == WSCWeatherStatTemperature) {
        NSString *valueString = @"";
        switch (value) {
            case WSCGameTemperatureCold:
                valueString = @"Cold";
                break;
            case WSCGameTemperatureCool:
                valueString = @"Cool";
                break;
            case WSCGameTemperatureMild:
                valueString = @"Mild";
                break;
            case WSCGameTemperatureWarm:
                valueString = @"Warm";
                break;
            case WSCGameTemperatureHot:
                valueString = @"Hot";
                break;
            
            default:
                break;
        }
        
        statPhrase = [NSString stringWithFormat:@"win percentage in %@ temperatures", valueString];
    }
    else if(row == WSCWeatherStatCondition) {
        NSString *valueString = @"";
        switch (value) {
            case WSCGameConditionCloudy:
                valueString = @"Cloudy";
                break;
            case WSCGameConditionFair:
                valueString = @"Fair";
                break;
            case WSCGameConditionFog:
                valueString = @"Foggy";
                break;
            case WSCGameConditionRain:
                valueString = @"Rainy";
                break;
            case WSCGameConditionSnow:
                valueString = @"Snowy";
                break;
            case WSCGameConditionSunny:
                valueString = @"Sunny";
                break;
            default:
                break;
        }
        
        statPhrase = [NSString stringWithFormat:@"win percentage in %@ weather", valueString];
        
    }
    else if(row == WSCWeatherStatHumidity) {
        NSString *valueString = @"";
        switch (value) {
            case WSCGameHumidityNone:
                valueString = @"No";
                break;
            case WSCGameHumidityLow:
                valueString = @"Low";
                break;
            case WSCGameHumidityMedium:
                valueString = @"Medium";
                break;
            case WSCGameHumidityHigh:
                valueString = @"High";
                break;
            default:
                break;
        }
        
        statPhrase = [NSString stringWithFormat:@"win percentage in %@ humidity", valueString];
    }
    else if(row == WscWeatherStatWind) {
        NSString *valueString = @"";
        switch (value) {
            case WSCGameWindNone:
                valueString = @"No";
                break;
            case WSCGameWindLow:
                valueString = @"Low";
                break;
            case WSCGameWindMedium:
                valueString = @"Medium";
                break;
            case WSCGameWindHigh:
                valueString = @"High";
                break;
            default:
                break;
        }
        
        statPhrase = [NSString stringWithFormat:@"win percentage in %@ wind", valueString];
    }
    else if(row == WSCWeatherStatPressure) {
        NSString *valueString = @"";
        switch (value) {
            case WSCGamePressureLow:
                valueString = @"Low";
                break;
            case WSCGamePressureMedium:
                valueString = @"Medium";
                break;
            case WSCGamePressureHigh:
                valueString = @"High";
                break;
            default:
                break;
        }
        
        statPhrase = [NSString stringWithFormat:@"win percentage in %@ pressure", valueString];
    }
    
    return statPhrase;
}
@end
