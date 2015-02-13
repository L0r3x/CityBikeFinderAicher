//
//  UIViewController+showInfosViewController.m
//  CityBikeFinder2
//
//  Created by Michael Aicher on 09.02.15.
//  Copyright (c) 2015 foryouandyourcustomers. All rights reserved.
//

#import "showInfosViewController.h"
#import "StationTableCell.h"

@interface showInfosViewController ()

@end

@implementation showInfosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any addtional things here after loading the view.
    NSLog(@"%lu", (unsigned long)_stationItems.count);
}

#pragma marks - TableView

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)_stationItems.count);
    return _stationItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stationCell";
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    StationTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
//    
//    cell.accessoryView = button;
    
    long row = [indexPath row];
    CityBikeStation *station = _stationItems[row];
    
    cell.kruzefixLabel.text = station.name;
    cell.verdammtesLabel.text = station.address;
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    StationTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    CityBikeStation *station = _stationItems[[indexPath row]];
//    
//    cell.kruzefixLabel.text = station.name;
//    cell.verdammtesLabel.text = station.address;
//
//    return cell;
//}


//- (void)checkButtonTapped:(id)sender event:(id)event
//{
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
//    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
//    if (indexPath != 0) {
//        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
//    }
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Segue to routing

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Routing to Station"])
    {
        RouteViewController *routeController = [segue destinationViewController]; //(RouteViewController *) segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        long row = indexPath.row;
        routeController.destination = _stationItems[row];
    }
}

#pragma mark - Button(s)

- (IBAction)doneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end