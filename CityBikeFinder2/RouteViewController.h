//
//  UIViewController+RouteViewController.h
//  CityBikeFinder2
//
//  Created by Michael Aicher on 13.02.15.
//  Copyright (c) 2015 foryouandyourcustomers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CityBikeMapsViewController.h"
#import "CityBikeStationObject.h"

@interface RouteViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    int currentDist;
    CLLocationCoordinate2D currentCentre;
}
@property (strong, nonatomic) IBOutlet MKMapView *routeMap;
@property (strong, nonatomic) CityBikeStation *destination;


@end
