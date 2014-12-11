//
//  WSCScheduleDay.h
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCScheduleDay : NSObject

@property (nonatomic, strong) NSDate          *date;
@property (nonatomic, strong) NSMutableArray  *games;

@end
