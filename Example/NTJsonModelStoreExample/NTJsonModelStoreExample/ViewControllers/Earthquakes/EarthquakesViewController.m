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


-(void)beginReload
{
    [Earthquake beginFindWhere:nil args:nil orderBy:@"magnitude desc" completionHandler:^(NSArray *earthquakes, NSError *error) {
        _earthquakes = earthquakes;
        [self.tableView reloadData];
    }];
}

-(void)beginRefreshDataFromServer
{
    self.navigationItem.rightBarButtonItem.title = @"...";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[ApiClient new] beginGetCategory:CategoryAll recent:RecentMonth responseHandler:^(GeoJSONFeatureCollection *collection, NSError *error) {
        
        self.navigationItem.rightBarButtonItem.title = @"Refesh";
        self.navigationItem.rightBarButtonItem.enabled = YES;

        // We only want actual earthquakes..
        
        NSMutableArray *earthquakes = [NSMutableArray array];
        
        for(GeoJSONFeature *feature in collection.features)
        {
            if ( [feature isKindOfClass:[Earthquake class]] )
                [earthquakes addObject:feature];
        }
        
        // for now, just delete existing and replace with our new values...
        
        [Earthquake beginRemoveAllWithCompletionHandler:^(int count, NSError *error) {}];
        [Earthquake beginInsertBatch:earthquakes completionHandler:^(NSError *error) {}];
        [Earthquake beginSyncWithCompletionHandler:^{
            [self beginReload];
        }];
    }];
}


- (void)viewDidLoad
{
    self.title = @"Earthquakes!";
    
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshAction:)];
    
    self.navigationItem.rightBarButtonItem = item;
    
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
    
    [self beginReload];
    
    [self beginRefreshDataFromServer];
}


-(void)refreshAction:(id)sender
{
    [self beginRefreshDataFromServer];
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
