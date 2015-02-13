//
//  UIViewController+RouteViewController.m
//  CityBikeFinder2
//
//  Created by Michael Aicher on 13.02.15.
//  Copyright (c) 2015 foryouandyourcustomers. All rights reserved.
//

#import "RouteViewController.h"

@implementation RouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _routeMap.showsUserLocation = YES;
    MKUserLocation *userLocation = _routeMap.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000);
    [_routeMap setRegion:region animated:NO];
    _routeMap.delegate = self;
    
    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    
    [self->locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self->locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [self->locationManager startUpdatingLocation];
    [self getDirections];
}

- (void)getDirections
{
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(_destination.coordinate.latitude, _destination.coordinate.longitude) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    request.destination = mapItem;
    request.requestsAlternateRoutes = NO;
    request.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle error
         } else {
             [self showRoute:response];
             MKPointAnnotation *target = [[MKPointAnnotation alloc] init];
             target.coordinate = _destination.coordinate;
             target.title =_destination.name;
             target.subtitle = _destination.address;
             [self.routeMap addAnnotation:target];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [_routeMap
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor greenColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

#pragma mark - automatic zoom to user location

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //center of Map is User Location
    [self.routeMap setCenterCoordinate:self.routeMap.userLocation.location.coordinate animated:NO];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
//    CLLocationCoordinate2D centre = [mapView centerCoordinate];
    MKCoordinateRegion region;
        MKUserLocation *userLocation = self.routeMap.userLocation;
        region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000);

    [self.routeMap setRegion:region animated:NO];
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKMapRect mRect = self.routeMap.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    currentDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    currentCentre = self.routeMap.centerCoordinate;
}

@end
