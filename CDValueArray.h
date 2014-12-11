//
//  WeatherlyticsValueArray.h
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDValueArray : NSManagedObject

@property (nonatomic, retain) NSNumber * value0;
@property (nonatomic, retain) NSNumber * value1;
@property (nonatomic, retain) NSNumber * value2;
@property (nonatomic, retain) NSNumber * value3;
@property (nonatomic, retain) NSNumber * value4;
@property (nonatomic, retain) NSNumber * value5;

@end
