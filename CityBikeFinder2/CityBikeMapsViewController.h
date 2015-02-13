//
//  ViewController.h
//  CityBikeFinder2
//
//  Created by Michael Aicher on 16.01.15.
//  Copyright (c) 2015 foryouandyourcustomers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ShowInfosViewController.h"
#import "CityBikeStationObject.h"

//#define kGOOGLE_API_KEY @"AIzaSyDNaIImbdn2sY5zkq8ds74IvBgBZxFhYfU"
#define kGOOGLE_API_KEY @"AIzaSyBhL84S7iYPTU2FMkRD9gYYVtD2kiMOOCs"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface cityBikeMapsViewController : UIViewController <UIApplicationDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate>
{
    CLLocationManager *locationManager;
    IBOutlet MKMapView *cityBikeMapView;
    CLLocationCoordinate2D currentCentre;
    int currentDist;
    BOOL initialLaunch;
}

@property (strong, nonatomic) IBOutlet MKMapView *cityBikeMapView;
@property (strong, nonatomic) NSMutableArray *matchingStations;


@property (strong, nonatomic) NSMutableArray *matchingItems;

- (IBAction)toggleStationSwitch:(id)sender;

@end

