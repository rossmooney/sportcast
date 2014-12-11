//
//  WSCWeatherlytics.m
//  SportCast
//
//  Created by Ross Mooney on 12/10/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCWeatherlytics.h"

@implementation WSCWeatherlytics

- (id) init
{
    if (self = [super init])
    {
        //Initialize with -1's so we know they haven't been used
        self.temperatureValues = @[@-1, @-1, @-1, @-1, @-1];
        self.windValues = @[@-1, @-1, @-1, @-1];
        self.humidityValues = @[@-1, @-1, @-1, @-1];
        self.conditionValues = @[@-1, @-1, @-1, @-1, @-1, @-1];
        self.pressureValues = @[@-1, @-1, @-1];
        self.stadiumTypeValues = @[@-1, @-1, @-1];
    }
    return self;
}

@end
