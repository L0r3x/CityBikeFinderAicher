//
//  ViewController.m
//  CityBikeFinder2
//
//  Created by Michael Aicher on 16.01.15.
//  Copyright (c) 2015 foryouandyourcustomers. All rights reserved.
//

#import "cityBikeMapsViewController.h"

@interface cityBikeMapsViewController ()

@end

@implementation cityBikeMapsViewController

@synthesize cityBikeMapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.cityBikeMapView setDelegate:self];

    self.cityBikeMapView.showsBuildings = YES;
    self.cityBikeMapView.showsPointsOfInterest = NO;

    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    // Check if iOS 8 is used. Without code will crash with "unknown selector" on iOS 7.
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    self.cityBikeMapView.showsUserLocation = YES;
    
    [self->locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self->locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [self->locationManager startUpdatingLocation];
    initialLaunch = YES;
}


#pragma mark - get those shitty citybike stations

-(void) queryGooglePlaces
{
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=CityBikeStation&location=%f,%f&radius=%@&sensor=true&key=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currentDist], kGOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* stations = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", stations);
    [self plotStations:stations];
}

-(void)plotStations:(NSArray *)data
{
    //Remove all existing stations
    for (id<MKAnnotation> annotation in cityBikeMapView.annotations)
    {
        if ([annotation isKindOfClass:[CityBikeStation class]]) {
            [cityBikeMapView removeAnnotation:annotation];
        }
    }
    
    _matchingStations = [[NSMutableArray alloc] init];
    
    // get the stations from Google API
    for (int i=0; i<[data count]; i++)
    {
        NSDictionary* station = [data objectAtIndex:i];
        NSDictionary *geo = [station objectForKey:@"geometry"];
        NSDictionary *loc = [geo objectForKey:@"location"];
        NSString *name = [station objectForKey:@"name"];
        NSString *stationAddress = [station objectForKey:@"formatted_address"];
        CLLocationCoordinate2D stationCoord;
        stationCoord.latitude = [[loc objectForKey:@"lat"] doubleValue];
        stationCoord.longitude = [[loc objectForKey:@"lng"] doubleValue];
        CityBikeStation *stationObject = [[CityBikeStation alloc] initWithName:name address:stationAddress coordinate:stationCoord];
        
        [_matchingStations addObject:stationObject];
        
        [cityBikeMapView addAnnotation:stationObject];
    }
}

#pragma mark - show stations on map

- (IBAction)toggleStationSwitch:(id)sender
{
    if ([sender isOn]) {
        [self queryGooglePlaces];
    }else {
        id userAnnotation = self.cityBikeMapView.userLocation;
        
        NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.cityBikeMapView.annotations];
        [annotations removeObject:userAnnotation];
        
        [self.cityBikeMapView removeAnnotations:annotations];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *identifier = @"CityBikeStation";
    UIImage *customAnnotationImage = [UIImage imageNamed:@"Citybike"];
    
    if ([annotation isKindOfClass:[CityBikeStation class]])
    {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.cityBikeMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
//        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.animatesDrop = NO;
        annotationView.image = customAnnotationImage;
        return annotationView;
    }
    return nil;
}

//#pragma mark - segue for routing
//
//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//{
//    [self performSegueWithIdentifier:@"RouteToStation" sender:view];
//}

#pragma mark - figure out some things about user location

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKMapRect mRect = self.cityBikeMapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    currentDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    currentCentre = self.cityBikeMapView.centerCoordinate;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //center of Map is User Location
    [self.cityBikeMapView setCenterCoordinate:self.cityBikeMapView.userLocation.location.coordinate animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - automatic zoom to user location

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    CLLocationCoordinate2D centre = [mapView centerCoordinate];
    MKCoordinateRegion region;
    if (initialLaunch) {
        MKUserLocation *userLocation = cityBikeMapView.userLocation;
        region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000);
        initialLaunch = NO;
    }else {
        region = MKCoordinateRegionMakeWithDistance(centre, currentDist, currentDist);
    }
    
    [cityBikeMapView setRegion:region animated:YES];
}

#pragma mark - segue to showInfos

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    showInfosViewController *destination = [segue destinationViewController];
    destination.stationItems = _matchingStations;
}

// Buttons

//- (IBAction)zoomToMyPosition:(id)sender
//{
//    MKUserLocation *userLocation = cityBikeMapView.userLocation;
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 300, 300);
//    
//    [cityBikeMapView setRegion:region animated:YES];
//}

@end
