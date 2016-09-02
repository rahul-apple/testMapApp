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
#define BUTTON_TITLE4 @"Stop Monitoring"
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
@interface ViewController () {
}

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  coordinatesArray = [[NSMutableArray alloc] init];
  [_mapView setShowsUserLocation:true];
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  [locationManager requestAlwaysAuthorization];
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  [locationManager startUpdatingLocation];
  [locationManager setAllowsBackgroundLocationUpdates:true];
  [self zoomToCurrentLocation:nil];
  _mapView.mapType = MKMapTypeHybrid;
  [segmentControl setSelectedSegmentIndex:2];
  [segmentControl.layer setCornerRadius:3.0f];
  [_next setTitle:BUTTON_TITLE1 forState:UIControlStateNormal];
  [self addLongPressGuesture];
  self.navigationItem.title = @"TEST MAP APP";
}

- (void)addLongPressGuesture {
  UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(handleLongPress:)];
  lpgr.minimumPressDuration = 0.5; // user needs to press for 2 seconds
  [self.mapView addGestureRecognizer:lpgr];
}
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
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
  float spanX = 0.005; // 0.00725;
  float spanY = 0.005; // 0.00725;
  MKCoordinateRegion region;
  region.center.latitude = self.mapView.userLocation.coordinate.latitude;
  region.center.longitude = self.mapView.userLocation.coordinate.longitude;
  region.span.latitudeDelta = spanX;
  region.span.longitudeDelta = spanY;
  [self.mapView setRegion:region animated:YES];
  //    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate
  //    animated:YES];
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
}

- (void)mapView:(MKMapView *)mapView
    didUpdateUserLocation:(MKUserLocation *)userLocation {
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
- (void)addtoCoodinates:(MKPointAnnotation *)annotate {
  [coordinatesArray addObject:annotate];
  if (coordinatesArray.count > 2) {
    [_next setTitle:BUTTON_TITLE2 forState:UIControlStateNormal];
  } else {
    [_next setTitle:BUTTON_TITLE1 forState:UIControlStateNormal];
  }
}

#pragma mark CoreLocation Delegates
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
  NSLog(@"%@", [locations lastObject]);
  CLLocationCoordinate2D coordinate =
      CLLocationCoordinate2DMake([locations lastObject].coordinate.latitude,
                                 [locations lastObject].coordinate.longitude);
  if ([_next.titleLabel.text isEqualToString:BUTTON_TITLE4]) {
    if (![self coordinate:coordinate inRegion:allowedRegion]) {
      [locationManager stopUpdatingLocation];
      [self showAlertWithTitle:@"Oops!"
                       andBody:@"You have reached out of allowed boundary"];
      [_next setTitle:BUTTON_TITLE3 forState:UIControlStateNormal];
    }
  }
}
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region {
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
}
- (void)locationManager:(CLLocationManager *)manager
    monitoringDidFailForRegion:(nullable CLRegion *)region
                     withError:(NSError *)error {
}
- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusDenied) {
    // permission denied
    [self showAlertWithTitle:@"Location Access Denied"
                     andBody:@"Please enable the location access"];
  } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
    // permission granted
  } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self showAlertWithTitle:@"Location Access Update Need"
                     andBody:@"This app required continous tracking,please "
                             @"enable 'Always'' for Location Access for the "
                             @"App"];
  }
}

- (void)showAlertWithTitle:(NSString *)title andBody:(NSString *)message {
  UIAlertController *alertVC =
      [UIAlertController alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancel =
      [UIAlertAction actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleCancel
                             handler:nil];
  [alertVC addAction:cancel];
  [self presentViewController:alertVC animated:true completion:nil];
}

- (IBAction)nextAction:(UIButton *)sender {
  if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE2]) {

    [_mapView removeOverlays:[_mapView overlays]];
    [self createPolyLineRegion];
    [sender setTitle:BUTTON_TITLE3 forState:UIControlStateNormal];
  } else if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE3]) {
    allowedRegion = [self regionForAnnotations:coordinatesArray];
    [locationManager startUpdatingLocation];
    [sender setTitle:BUTTON_TITLE4 forState:UIControlStateNormal];
  } else if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE4]) {
    [locationManager stopUpdatingLocation];
    [sender setTitle:BUTTON_TITLE3 forState:UIControlStateNormal];
  }
}

- (IBAction)reset:(id)sender {
  if ([_next.titleLabel.text isEqualToString:BUTTON_TITLE4] ||
      [_next.titleLabel.text isEqualToString:BUTTON_TITLE3]) {
    [coordinatesArray removeAllObjects];
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:[_mapView overlays]];
    [locationManager stopUpdatingLocation];
    [_next setTitle:BUTTON_TITLE1 forState:UIControlStateNormal];
  }
}

- (void)createPolyLineRegion {

  CLLocationCoordinate2D coordinateArray[coordinatesArray.count];
  for (MKPointAnnotation *annote in coordinatesArray) {
    coordinateArray[[coordinatesArray indexOfObject:annote]] =
        CLLocationCoordinate2DMake(annote.coordinate.latitude,
                                   annote.coordinate.longitude);
  }
  coordinateArray[coordinatesArray.count] = coordinateArray[0];
  self.routeLine =
      [MKPolyline polylineWithCoordinates:coordinateArray
                                    count:coordinatesArray.count + 1];
  [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]]; // If you
                                                                     // want the
                                                                     // route to
                                                                     // be
                                                                     // visible
  [self.mapView addOverlay:self.routeLine];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id<MKOverlay>)overlay {
  if (overlay == self.routeLine) {
    self.routeLineView =
        [[MKPolylineView alloc] initWithPolyline:self.routeLine];
    self.routeLineView.fillColor = [UIColor redColor];
    self.routeLineView.strokeColor = [UIColor redColor];
    self.routeLineView.lineWidth = 5;
    return self.routeLineView;
  }
  return nil;
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
  CLLocationDegrees minLat = 90.0;
  CLLocationDegrees maxLat = -90.0;
  CLLocationDegrees minLon = 180.0;
  CLLocationDegrees maxLon = -180.0;
  for (MKPointAnnotation *annotation in annotations) {
    if (annotation.coordinate.latitude < minLat) {
      minLat = annotation.coordinate.latitude;
    }
    if (annotation.coordinate.longitude < minLon) {
      minLon = annotation.coordinate.longitude;
    }
    if (annotation.coordinate.latitude > maxLat) {
      maxLat = annotation.coordinate.latitude;
    }
    if (annotation.coordinate.longitude > maxLon) {
      maxLon = annotation.coordinate.longitude;
    }
  }
  MKCoordinateSpan span =
      MKCoordinateSpanMake(maxLat - minLat, maxLon - minLon);
  CLLocationCoordinate2D center = CLLocationCoordinate2DMake(
      (maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2);
  return MKCoordinateRegionMake(center, span);
}
- (BOOL)coordinate:(CLLocationCoordinate2D)coord
          inRegion:(MKCoordinateRegion)region {
  CLLocationCoordinate2D center = region.center;
  MKCoordinateSpan span = region.span;
  BOOL result = YES;
  result &= cos((center.latitude - coord.latitude) * M_PI / 180.0) >
            cos(span.latitudeDelta / 2.0 * M_PI / 180.0);
  result &= cos((center.longitude - coord.longitude) * M_PI / 180.0) >
            cos(span.longitudeDelta / 2.0 * M_PI / 180.0);
  return result;
}
@end
