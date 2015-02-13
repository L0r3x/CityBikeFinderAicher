//
//  StationTableCell.h
//  CityBikeFinder2
//
//  Created by Michael Aicher on 12.02.15.
//  Copyright (c) 2015 foryouandyourcustomers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationTableCell : UITableViewCell <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *kruzefixLabel;
@property (strong, nonatomic) IBOutlet UILabel *verdammtesLabel;

@end
