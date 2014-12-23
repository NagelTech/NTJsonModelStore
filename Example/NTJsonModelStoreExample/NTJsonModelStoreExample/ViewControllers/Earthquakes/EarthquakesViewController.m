//
//  EarthquakesViewController.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "EarthquakesViewController.h"

#import "ApiClient.h"

#import "Earthquake.h"


@interface EarthquakesViewController () <UITableViewDataSource, UITableViewDelegate>
{
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,readonly) NSArray *earthquakes;

@end


@implementation EarthquakesViewController


- (void)viewDidLoad
{
    self.title = @"Earthquakes!";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ApiClient new] beginGetCategory:CategoryAll recent:RecentMonth responseHandler:^(GeoJSONFeatureCollection *earthquakes, NSError *error) {
        
        _earthquakes = earthquakes.features;
        [self.tableView reloadData];
    }];
}


#pragma mark - UITableViewDataSource/Delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.earthquakes.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Earthquake *earthquake = self.earthquakes[indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
    
    cell.textLabel.text = earthquake.title;
    
    return cell;
}


@end
