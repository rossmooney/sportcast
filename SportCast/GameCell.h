//
//  GameCell.h
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WSCWeatherStatCondition,
    WSCWeatherStatTemperature,
    WscWeatherStatWind,
    WSCWeatherStatPressure,
    WSCWeatherStatHumidity
} WSCWeatherStatEnum;

@class WSCGame, WSCMainViewController;
@interface GameCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel        *homeTeam;
@property (nonatomic, weak) IBOutlet UILabel        *awayTeam;
@property (nonatomic, weak) IBOutlet UILabel        *homeTeamDetail;
@property (nonatomic, weak) IBOutlet UILabel        *awayTeamDetail;
@property (nonatomic, weak) IBOutlet UILabel        *homeRecord;
@property (nonatomic, weak) IBOutlet UILabel        *awayRecord;
@property (nonatomic, weak) IBOutlet UILabel        *temperature;
@property (nonatomic, weak) IBOutlet UILabel        *detailWeather;
@property (nonatomic, weak) IBOutlet UIImageView        *weatherIcon;
@property (nonatomic, weak) IBOutlet UICollectionView *homeCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *awayCollectionView;
@property (nonatomic, weak) WSCMainViewController *mainViewController;

@property (nonatomic, assign) BOOL                  hasWeatherData;


@property (nonatomic, weak) IBOutlet UIView         *awayTeamContainer;
@property (nonatomic, weak) IBOutlet UIView         *homeTeamContainer;
@property (nonatomic, strong) WSCGame *game;

+ (NSString *)statPhraseForRow:(NSInteger)row withValue:(NSUInteger)value andIsShort:(BOOL)isShort;
@end
