//
//  WSCCoreDataManager.m
//  SportCast
//
//  Created by Ross Mooney on 12/11/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCCoreDataManager.h"
#import "WSCGame.h"
#import "WSCWeatherlytics.h"
#import "CDGame.h"
#import "CDValueArray.h"
#import "CDTeamWeatherlytics.h"

@implementation WSCCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark Singleton Methods

+ (id)sharedInstance {
    static WSCCoreDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - App Specific Methods

- (void)saveGames:(NSArray *)games {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(WSCGame *game in games) {

        //Check if game is already saved
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gameid = %ld", game.gameId];
        [fetchRequest setPredicate:predicate];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CDGame"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        CDGame *cdGame;
        if(fetchedObjects.count > 0) {
            //if yes, update it
            cdGame = (CDGame *)fetchedObjects[0];
            
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't update: %@", [error localizedDescription]);
            }
        }
        else {
            //otherwise create new record
            cdGame = (CDGame *)[NSEntityDescription
                                       insertNewObjectForEntityForName:@"CDGame"
                                       inManagedObjectContext:context];

        }
        cdGame.gameid = [NSString stringWithFormat:@"%ld",game.gameId];
        cdGame.homeTeam = game.homeTeam;
        cdGame.awayTeam = game.awayTeam;
        cdGame.homeScore = game.homeScore;
        cdGame.awayScore = game.awayScore;
        cdGame.date = game.date;
        cdGame.gameCondition = @(game.gameCondition);
        cdGame.gameHumidity = @(game.gameHumidity);
        cdGame.gameTemperature = @(game.gameTemperature);
        cdGame.gamePressure = @(game.gamePressure);
        cdGame.gameWind = @(game.gameWind);
        cdGame.isFinal = @(game.isFinal);
    
        //save changes
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}


- (NSArray *)loadGames {
    NSMutableArray *gameArray = [NSMutableArray array];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CDGame"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    for(CDGame *cdGame in fetchedObjects) {
        WSCGame *game = [[WSCGame alloc] init];
        game.homeTeam = cdGame.homeTeam;
        game.awayTeam = cdGame.awayTeam;
        game.homeScore = cdGame.homeScore;
        game.awayScore = cdGame.awayScore;
        game.date = cdGame.date;
        game.gameCondition = [cdGame.gameCondition integerValue];
        game.gameHumidity = [cdGame.gameHumidity integerValue];
        game.gameTemperature = [cdGame.gameTemperature integerValue];
        game.gamePressure = [cdGame.gamePressure integerValue];
        game.gameWind = [cdGame.gameWind integerValue];
        game.gameId = [cdGame.gameid longLongValue];;
        //We only save games that have been analyzed
        game.isFinal = [cdGame.isFinal boolValue];
        game.analyzed = YES;
        
        [gameArray addObject:game];
    }
    
    return gameArray;
}


- (void)saveWeatherlytics:(NSArray *)leagueWeatherlytics {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(WSCWeatherlytics *weatherlytics in leagueWeatherlytics) {
        //Check if game is already saved
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team = %@", weatherlytics.team];
        [fetchRequest setPredicate:predicate];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CDTeamWeatherlytics"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        CDTeamWeatherlytics *cdTeamWeatherlytics;
        if(fetchedObjects.count > 0) {
            //if yes, update it
            cdTeamWeatherlytics = (CDTeamWeatherlytics *)fetchedObjects[0];
            
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't update: %@", [error localizedDescription]);
            }
        }
        else {
            //otherwise create new record
            cdTeamWeatherlytics = (CDTeamWeatherlytics *)[NSEntityDescription
                                insertNewObjectForEntityForName:@"CDTeamWeatherlytics"
                                inManagedObjectContext:context];
            
        }

        cdTeamWeatherlytics.team = weatherlytics.team;
        cdTeamWeatherlytics.startDate = weatherlytics.startDate;
        cdTeamWeatherlytics.endDate = weatherlytics.endDate;
        cdTeamWeatherlytics.temperatureValues = [self valueArrayFromNumberArray:weatherlytics.temperatureValues];
        cdTeamWeatherlytics.windValues = [self valueArrayFromNumberArray:weatherlytics.windValues];
        cdTeamWeatherlytics.pressureValues = [self valueArrayFromNumberArray:weatherlytics.pressureValues];
        cdTeamWeatherlytics.humidityValues = [self valueArrayFromNumberArray:weatherlytics.humidityValues];
        
        cdTeamWeatherlytics.conditionValues = [self valueArrayFromNumberArray:weatherlytics.conditionValues];
        
        //save changes
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (NSArray *)loadWeatherlytics {
    NSMutableArray *weatherlyticsArray = [NSMutableArray array];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CDTeamWeatherlytics"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for(CDTeamWeatherlytics *cdTeamWeatherlytics in fetchedObjects) {
        WSCWeatherlytics *weatherlytics = [[WSCWeatherlytics alloc] init];
        
        weatherlytics.team = cdTeamWeatherlytics.team;
        weatherlytics.startDate = cdTeamWeatherlytics.startDate;
        weatherlytics.endDate = cdTeamWeatherlytics.endDate;
        weatherlytics.temperatureValues = [self numberArrayFromValueArray:cdTeamWeatherlytics.temperatureValues withCount:5];
        weatherlytics.windValues = [self numberArrayFromValueArray:cdTeamWeatherlytics.temperatureValues withCount:4];
        weatherlytics.pressureValues = [self numberArrayFromValueArray:cdTeamWeatherlytics.temperatureValues withCount:3];
        weatherlytics.humidityValues = [self numberArrayFromValueArray:cdTeamWeatherlytics.temperatureValues withCount:4];
        
        weatherlytics.conditionValues = [self numberArrayFromValueArray:cdTeamWeatherlytics.temperatureValues withCount:6];
        
        [weatherlyticsArray addObject:weatherlytics];
    }
    
    return weatherlyticsArray;
}

#pragma mark - Core Data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SportCastDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SportCast.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Helper Methods

- (CDValueArray *)valueArrayFromNumberArray:(NSArray *)numberArray {
     NSManagedObjectContext *context = [self managedObjectContext];
    CDValueArray *valueArray = (CDValueArray *)[NSEntityDescription
                                                  insertNewObjectForEntityForName:@"CDValueArray"
                                                  inManagedObjectContext:context];
    if(numberArray.count > 0) {
        valueArray.value0 = numberArray[0];
    }
    if(numberArray.count > 1) {
        [valueArray setValue1:numberArray[1]];
    }
    if(numberArray.count > 2) {
        [valueArray setValue2:numberArray[2]];
    }
    if(numberArray.count > 3) {
        [valueArray setValue3:numberArray[3]];
    }
    if(numberArray.count > 4) {
        [valueArray setValue4:numberArray[4]];
    }
    if(numberArray.count > 5) {
        [valueArray setValue5:numberArray[5]];
    }
    
    return valueArray;
}

- (NSArray *)numberArrayFromValueArray:(CDValueArray *)valueArray withCount:(NSUInteger)count {
    NSArray *numberArray = [NSArray arrayWithObjects:valueArray.value0, valueArray.value1, valueArray.value2, valueArray.value3, valueArray.value4, valueArray.value5, nil];
    
    NSArray *returnArray = [numberArray subarrayWithRange:NSMakeRange(0, count)];
    
    return returnArray;
}

@end
