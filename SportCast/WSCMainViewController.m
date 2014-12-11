//
//  ViewController.m
//  SportCast
//
//  Created by Ross Mooney on 12/9/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCMainViewController.h"
#import "WSCProFootballAPI.h"
#import "WSCWeatherlyticsGenerator.h"
#import "AppDelegate.h"
#import "WSCCoreDataManager.h"
#import "CDGame.h"
#import "WSCScheduleDay.h"
#import "WSCGame.h"
#import "NSDate+NoTime.h"
#import "GameCell.h"
#import "SectionHeaderCell.h"
#import "WXWeatherDataService/WXWeatherDataService.h"


@interface WSCMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *schedule;
@property (nonatomic, weak) IBOutlet UITableView *scheduleTableView;
@property (nonatomic, strong) NSDictionary *teamData;

@end

@implementation WSCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [[WSCProFootballAPI sharedInstance] setGames: [[WSCCoreDataManager sharedInstance] loadGames]];
//    [self runAnalysis];
//    
    [self loadTeamData];
    [self loadSchedule];
    
    self.scheduleTableView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTeamData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"teamLocations" ofType:@"json"];
    NSData *teamData = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:teamData options:0 error:&localError];
    
    self.teamData = parsedObject;
}

- (void)loadSchedule {
    
    
    [[WSCProFootballAPI sharedInstance] requestUpcomingGamesForDays:7 withCompletion:^(NSArray *games) {
        NSMutableArray *schedule = [NSMutableArray array];
        for(WSCGame *game in games) {

            BOOL dayExists = NO;
            for(WSCScheduleDay *day in schedule) {
                if([[day.date dateWithoutTime] isEqualToDate:[game.date dateWithoutTime]]) {
                    [day.games addObject:game];
                    dayExists = YES;
                    break;
                }
            }
            
            if(!dayExists) {
                WSCScheduleDay *day = [[WSCScheduleDay alloc] init];
                day.date = [game.date dateWithoutTime];
                day.games = [NSMutableArray array];
                [day.games addObject:game];
                [schedule addObject:day];
            }
        }
        
        self.schedule = schedule;
        
        [self.scheduleTableView reloadData];
    }];
}

#pragma mark - Weatherlytics Analysis 

- (void)runAnalysis {
    [[WSCProFootballAPI sharedInstance] requestAllGamesWithCompletion:^(NSArray *games) {
        [[WSCWeatherlyticsGenerator sharedInstance] generateWeatherlyticsWithGames:games andCompletionHandler:^{
            
        }];
        
    }];

}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.schedule.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WSCScheduleDay *day = self.schedule[section];
    return day.games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"GameCell";
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = (GameCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }

    cell.backgroundColor = [UIColor clearColor];
    
    WSCScheduleDay *day = self.schedule[indexPath.section];
    WSCGame *game = day.games[indexPath.row];
    
    cell.homeTeam.text = [[self.teamData objectForKey:game.homeTeam] objectForKey:@"shortName"];
    cell.awayTeam.text = [[self.teamData objectForKey:game.awayTeam] objectForKey:@"shortName"];
    
    if(!cell.hasWeatherData && indexPath.section == 0 && indexPath.row == 0) {
        [self requestWeatherDataForCell:cell withGame:game];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *cellIdentifier = @"dateSectionHeader";
    SectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = (SectionHeaderCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    WSCScheduleDay *day = [self.schedule objectAtIndex:section];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM dd"];
    NSString *convertedDateString = [dateFormatter stringFromDate:day.date];
    
    cell.date.text = convertedDateString;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Weather Data

- (void)requestWeatherDataForCell:(GameCell *)cell withGame:(WSCGame *)game {
    cell.hasWeatherData = YES;
    NSString *coordinates = [[self.teamData objectForKey:game.homeTeam] objectForKey:@"stadiumCoordinates"];
    [[WXWeatherDataService sharedInstance] requestDailyForecastWithLocationKey:coordinates completionHandler:^(NSArray *dailyForecast, NSError *error) {
        
        
        for(WXDailyForecast *forecast in dailyForecast) {
            if([[forecast.forecastDateUTC dateWithoutTime] isEqualToDate:[game.date dateWithoutTime]]) {
                cell.temperature.text = forecast.temperature.high;
                cell.weatherIcon.image = (UIImage *)forecast.weatherIcon;
                cell.detailWeather.text = forecast.phrase12;
            }
        }
    }];
}

@end
