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


@interface WSCMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *schedule;
@property (nonatomic, weak) IBOutlet UITableView *scheduleTableView;

@end

@implementation WSCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [[WSCProFootballAPI sharedInstance] setGames: [[WSCCoreDataManager sharedInstance] loadGames]];
//    [self runAnalysis];
//    
    
    [self loadSchedule];
    
    self.scheduleTableView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }

    cell.backgroundColor = [UIColor clearColor];
    // Do something to cell
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *cellIdentifier = @"dateSectionHeader";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    // Do something to cell
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
