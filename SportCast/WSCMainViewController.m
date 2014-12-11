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


@interface WSCMainViewController ()


@end

@implementation WSCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[WSCProFootballAPI sharedInstance] setGames: [[WSCCoreDataManager sharedInstance] loadGames]];
    [self runAnalysis];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Weatherlytics Analysis 

- (void)runAnalysis {
    [[WSCProFootballAPI sharedInstance] requestAllGamesWithCompletion:^(NSArray *games) {
        [[WSCWeatherlyticsGenerator sharedInstance] generateWeatherlyticsWithGames:games andCompletionHandler:^{
            
        }];
        
    }];

}


@end
