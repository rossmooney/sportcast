//
//  NSDate+NoTime.m
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "NSDate+NoTime.h"

@implementation NSDate (NoTime)

- (NSDate *)dateWithoutTime {
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:flags
                                                                   fromDate:self];
    NSString *stringDate = [NSString stringWithFormat:@"%d/%d/%d", components.day, components.month, components.year];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    
    return [formatter dateFromString:stringDate];
}

@end
