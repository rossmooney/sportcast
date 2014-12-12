//
//  StatDetailCell.h
//  SportCast
//
//  Created by Ross Mooney on 12/12/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCWeatherlytics.h"

@interface StatDetailCell : UICollectionViewCell

@property (nonatomic, strong) WSCWeatherlytics *teamWeatherlytics;
@property (nonatomic, assign) NSInteger weatherStatType;

- (void)buildProgressBars;

@end
