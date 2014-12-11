//
//  TeamWeatherlytics.h
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDValueArray;

@interface CDTeamWeatherlytics : NSManagedObject

@property (nonatomic, retain) NSString * team;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) CDValueArray *temperatureValues;
@property (nonatomic, retain) CDValueArray *windValues;
@property (nonatomic, retain) CDValueArray *pressureValues;
@property (nonatomic, retain) CDValueArray *conditionValues;
@property (nonatomic, retain) CDValueArray *humidityValues;

@end
