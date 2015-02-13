//
//  showInfosViewController.h
//  CityBikeFinder2
//
//  Created by Michael Aicher on 09.02.15.
//  Copyright (c) 2015 foryouandyourcustomers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "StationTableCell.h"
#import "CityBikeStationObject.h"
#import "RouteViewController.h"

@interface showInfosViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *stationItems;

- (IBAction)doneButton:(id)sender;

@end
