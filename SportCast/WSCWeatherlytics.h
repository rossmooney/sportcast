//
//  WSCWeatherlytics.h
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCWeatherlytics : NSObject

@property (nonatomic, assign) NSUInteger    gameId;
@property (nonatomic, strong) NSDate        *startDate;
@property (nonatomic, strong) NSDate        *endDate;
@property (nonatomic, strong) NSString      *team;
@property (nonatomic, strong) NSArray       *temperatureValues;
@property (nonatomic, strong) NSArray       *windValues;
@property (nonatomic, strong) NSArray       *pressureValues;
@property (nonatomic, strong) NSArray       *humidityValues;
@property (nonatomic, strong) NSArray       *conditionValues;
@property (nonatomic, strong) NSArray       *dayNightValues;
@property (nonatomic, strong) NSArray       *stadiumTypeValues;


@end
