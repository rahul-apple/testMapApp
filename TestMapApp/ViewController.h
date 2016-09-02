//
//  ViewController.h
//  TestMapApp
//
//  Created by RAHUL'S MAC MINI on 02/09/16.
//  Copyright © 2016 iDev. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKPolyline.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
@interface ViewController
    : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
  CLLocationManager *locationManager;
  NSMutableArray *coordinatesArray;
  MKCoordinateRegion allowedRegion;
  IBOutlet UISegmentedControl *segmentControl;
}
@property(strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) MKPolyline *routeLine;
@property(nonatomic, retain) MKPolylineView *routeLineView;
@property(strong, nonatomic) IBOutlet UIButton *next;
- (IBAction)setMapType:(id)sender;
- (IBAction)nextAction:(UIButton *)sender;
- (IBAction)reset:(id)sender;

@end
