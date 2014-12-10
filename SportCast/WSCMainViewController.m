//
//  ViewController.m
//  SportCast
//
//  Created by Ross Mooney on 12/9/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCMainViewController.h"
#import "WSCProFootballAPI.h"

@interface WSCMainViewController ()

@end

@implementation WSCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[WSCProFootballAPI sharedInstance] requestAllGames];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end