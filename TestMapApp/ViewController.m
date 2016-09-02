//
//  ViewController.m
//  TestMapApp
//
//  Created by RAHUL'S MAC MINI on 02/09/16.
//  Copyright © 2016 iDev. All rights reserved.
//

#import "ViewController.h"
#define BUTTON_TITLE1 @"Long Press on map to Drop Points"
#define BUTTON_TITLE2 @"Create a Region"
#define BUTTON_TITLE3 @"Start Monitoring"
@interface ViewController (){
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    coordinatesArray = [[NSMutableArray alloc]init];
    [_mapView setShowsUserLocation:true];
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate =self;
    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [locationManager setAllowsBackgroundLocationUpdates:true];
    [self zoomToCurrentLocation:nil];
    [_next setTitle:BUTTON_TITLE1 forState:UIControlStateNormal];
    [self addLongPressGuesture];
}

-(void)addLongPressGuesture{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
}
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:annot];
    [self addtoCoodinates:annot];
}

- (IBAction)zoomToCurrentLocation:(UIBarButtonItem *)sender {
    float spanX = 0.005;//0.00725;
    float spanY = 0.005;//0.00725;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setMapType:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

#pragma mark Save the Coordiantes
-(void)addtoCoodinates:(MKPointAnnotation *)annotate{
    [coordinatesArray addObject:annotate];
    if (coordinatesArray.count>2) {
        [_next setTitle:BUTTON_TITLE2 forState:UIControlStateNormal];
    }else{
        [_next setTitle:BUTTON_TITLE1 forState:UIControlStateNormal];
    }
    
}


#pragma mark CoreLocation Delegates
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%@", [locations lastObject]);
}
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region{
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
}
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error{
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        // permission denied
        [self showAlertWithTitle:@"Location Access Denied" andBody:@"Please enable the location access"];
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        // permission granted
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self showAlertWithTitle:@"Location Access Update Need" andBody:@"This app required continous tracking,please enable 'Always'' for Location Access for the App"];
        
    }
}

-(void)showAlertWithTitle:(NSString *)title andBody:(NSString *)message{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertVC animated:true completion:nil];
    
}

- (IBAction)nextAction:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE2]) {
        [self createPolyLineRegion];
    }
}

-(void)createPolyLineRegion{
    
    CLLocationCoordinate2D coordinateArray[coordinatesArray.count];
    for(MKPointAnnotation *annote in coordinatesArray){
        coordinateArray[[coordinatesArray indexOfObject:annote]] = CLLocationCoordinate2DMake(annote.coordinate.latitude, annote.coordinate.longitude);
    }
    coordinateArray[coordinatesArray.count] = coordinateArray[0];
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:coordinatesArray.count+1];
    [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]]; //If you want the route to be visible
    [self.mapView addOverlay:self.routeLine];
    
    
    
    /*MKMapPoint northEastPoint;
    MKMapPoint southWestPoint;
    
    MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * coordinatesArray.count);
    
    for(int idx = 0; idx < coordinatesArray.count; idx++)
    {
        MKPointAnnotation* currentPointString = [coordinatesArray objectAtIndex:idx];
        CLLocationDegrees latitude = currentPointString.coordinate.latitude;
        CLLocationDegrees longitude = currentPointString.coordinate.longitude;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        if (idx == 0) {
            northEastPoint = point;
            southWestPoint = point;
        }
        else
        {
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if(point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        pointArr[idx] = point;
    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArr count:coordinatesArray.count+1];
    [self.mapView addOverlay:self.routeLine];
    MKMapRect routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    [self.mapView setVisibleMapRect:routeRect];
    free(pointArr);*/
    
    
    
    
    
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    for (id<MKOverlay> overlayToRemove in self.mapView.overlays)
    {
        if ([overlayToRemove isKindOfClass:[MKPolylineView class]])
        {
            [mapView removeOverlay:overlayToRemove];
        }
    }
    
    if(overlay == self.routeLine)
    {
//        if(nil == self.routeLineView)
//        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor redColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 5;
            
//        }
        
        return self.routeLineView;
    }
    
    return nil;
}

@end
