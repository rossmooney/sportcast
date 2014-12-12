//
//  StatDetailCell.m
//  SportCast
//
//  Created by Ross Mooney on 12/12/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "StatDetailCell.h"
#import "GameCell.h"
#import "WSCGame.h"

#define DegreesToRadians(d) ((d) * M_PI / 180.0)

@interface StatDetailCell ()

@property (nonatomic, strong) NSMutableArray *bars;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, weak) IBOutlet UILabel *statTitle;

@end

@implementation StatDetailCell



- (void)buildProgressBars {
    
    NSArray *weatherlyticsArray;
    NSInteger numberOfBars = 0;
    switch(self.weatherStatType) {
        case WSCWeatherStatCondition:
            self.statTitle.text = @"Condition";
            weatherlyticsArray = self.teamWeatherlytics.conditionValues;
            numberOfBars = 6;
            break;
        case WSCWeatherStatHumidity:
            self.statTitle.text = @"Humidity";
            weatherlyticsArray = self.teamWeatherlytics.humidityValues;
            numberOfBars = 4;
            break;
        case WSCWeatherStatPressure:
            self.statTitle.text = @"Pressure";
            weatherlyticsArray = self.teamWeatherlytics.pressureValues;
            numberOfBars = 3;
            break;
        case WSCWeatherStatTemperature:
            self.statTitle.text = @"Temperature";
            weatherlyticsArray = self.teamWeatherlytics.temperatureValues;
            numberOfBars = 5;
            break;
        case WscWeatherStatWind:
            self.statTitle.text = @"Wind";
            weatherlyticsArray = self.teamWeatherlytics.windValues;
            numberOfBars = 4;
            break;
    }
    
    int screenWidth = self.frame.size.width;
    int barWidth = 100;
    int barSpacing = screenWidth / numberOfBars;
    int barY = 70;
    int barHeight = 400;
    
    for(int i = 0; i < numberOfBars; i++) {
        UIProgressView *bar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

        int barX = -60 + i * barSpacing + 0.5 * barWidth;
        
        bar.frame = CGRectMake(barX, barY, barWidth, barHeight);
        bar.progress = [weatherlyticsArray[i] floatValue];
        
        [self addSubview:bar];
        [self.bars addObject:bar];
    
        CGAffineTransform rotate = CGAffineTransformMakeRotation( M_PI * -0.5 );
        CGAffineTransform scale = CGAffineTransformMakeScale(1.0f, 10.0f);
        bar.transform = CGAffineTransformConcat(scale, rotate);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(barX + 33, self.frame.size.height - 25, 70, 20)];
        label.textColor = [UIColor lightGrayColor];
        label.text = [GameCell statPhraseForRow:self.weatherStatType withValue:i andIsShort:YES];
        [self addSubview:label];
        [self.labels addObject:label];
    }
    
    [self setNeedsLayout];
}

@end
