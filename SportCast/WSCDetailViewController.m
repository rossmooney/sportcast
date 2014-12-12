//
//  WSCDetailViewController.m
//  SportCast
//
//  Created by Ross Mooney on 12/12/14.
//  Copyright (c) 2014 TWC. All rights reserved.
//

#import "WSCDetailViewController.h"
#import "StatDetailCell.h"

@interface WSCDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *teamName;
@property (nonatomic, weak) IBOutlet UICollectionView *detailsCollectionView;


@end

@implementation WSCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = [[self.teamData objectForKey:self.teamWeatherlytics.team] objectForKey:@"longName"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"StatDetailCell";
    StatDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.weatherStatType = indexPath.row;
    cell.teamWeatherlytics = self.teamWeatherlytics;
    [cell buildProgressBars];
    
    return cell;
    
}


@end
