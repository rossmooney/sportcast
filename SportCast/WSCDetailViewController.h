//
//  WSCDetailViewController.h
//  SportCast
//
//  Created by Ross Mooney on 12/12/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCWeatherlytics.h"

@interface WSCDetailViewController : UIViewController

@property (nonatomic, strong) WSCWeatherlytics *teamWeatherlytics;
@property (nonatomic, strong) NSDictionary *teamData;

@end
