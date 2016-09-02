//
//  ViewController.h
//  TestMapApp
//
//  Created by RAHUL'S MAC MINI on 02/09/16.
//  Copyright © 2016 iDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKPolyline.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    NSMutableArray  *coordinatesArray;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MKPolyline *routeLine; //your line
@property (nonatomic, retain) MKPolylineView *routeLineView; //overlay view
@property (strong, nonatomic) IBOutlet UIButton *next;
- (IBAction)setMapType:(id)sender;
- (IBAction)nextAction:(UIButton *)sender;



@end

