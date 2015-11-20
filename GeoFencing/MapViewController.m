//
//  ViewController.m
//  GeoFencing
//
//  Created by Raghav Sai Cheedalla on 9/30/15.
//  Copyright © 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "MapViewController.h"
#import "GeofenceEditViewController.h"
#import "GeoTag.h"
#import "GeoCoreDataModel.h"
#import "GeoContainer.h"

@interface MapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,GeofencingProtocol>

@property (nonatomic, strong) CLLocationManager     *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView      *mapViewGeofence;
@property (weak, nonatomic) IBOutlet UIButton       *btnList;

@property (nonatomic, assign) NSUInteger            annotationIndex;
@property (nonatomic, assign) GeoCoreDataModel      *geoCoreDataModel;
@property (nonatomic, strong) NSArray               *geoArray;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupNavigationBar];
    [self initialSetup];
    [self getCurrentLocation];
    [self loadAnnotations];
}

#pragma mark - UI setup
- (void)setupNavigationBar
{
    [self setupTitle];
    [self setupRightBarButton];
}

- (void)setupTitle
{
    self.navigationItem.title = @"Geofence";
}

- (void)setupRightBarButton
{
    UIBarButtonItem *dropGeoPinBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(dropAnnotation)];
    self.navigationItem.rightBarButtonItem = dropGeoPinBarButton;
}

#pragma mark - Initial Setup
- (void)initialSetup
{
    self.geoCoreDataModel = [GeoCoreDataModel coreDataDefaultManager];
}
- (void)getCurrentLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locationManager requestAlwaysAuthorization];
    self.mapViewGeofence.delegate = self;
}


- (void)loadAnnotations
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf)
        {
            GeoContainer *geoContainer = [strongSelf.geoCoreDataModel getGeoFenceData];
            strongSelf.geoArray = geoContainer.geoContainerArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf addAnnotationsToMap:strongSelf.geoArray];
            });
        }
    });
}

#pragma mark - Helper methods
- (void)addAnnotationsToMap:(NSArray *)geoTempArray
{
    for(GeoTag *geoTag in geoTempArray)
    {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = geoTag.geoTagTitle;
        annotation.coordinate = CLLocationCoordinate2DMake(geoTag.latitude, geoTag.longitude);
        [self.mapViewGeofence addAnnotation:annotation];
//        [self setupUIGeoRegion:annotation withRadius:geoTag.radius];
        [self setGeoFence:annotation withRadius:geoTag.radius];
    }
}

- (void)showAlertWithMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedAlways)
    {
        self.mapViewGeofence.showsUserLocation = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"%@",region.identifier);
    [self showAlertWithMessage:region.identifier withTitle:@"entered"];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self showAlertWithMessage:region.identifier withTitle:@"exited"];
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Now monitoring for %@", region.identifier);
    [self.locationManager performSelector:@selector(requestStateForRegion:) withObject:region afterDelay:1];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"state %ld,%@",(long)state,region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error : %@",error);

}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(NSError *)error
{
    NSLog(@"%@",error);
    if(error.code == kCLErrorRegionMonitoringDenied)
        NSLog(@"ok");
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:nil];
        [self setAnnotationView:annotationView];
        return annotationView;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    return circleView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    GeofenceEditViewController *geofenceEditViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([GeofenceEditViewController class])];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:geofenceEditViewController];
    self.annotationIndex = [self.mapViewGeofence.annotations indexOfObject:view.annotation];
    geofenceEditViewController.annotationIndex = self.annotationIndex;
    geofenceEditViewController.geofenceDelegate = self;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - GeofencingProtocol methods
- (void)addGeofence:(GeoTag *)geoTag
{
    MKPointAnnotation *annotation = [self.mapViewGeofence.annotations objectAtIndex:geoTag.geoTagID];
    MKAnnotationView *annotationView = [self.mapViewGeofence viewForAnnotation:annotation];
    annotation.title = geoTag.geoTagTitle;
    annotationView.draggable = NO;
    [self setGeoFence:annotation withRadius:geoTag.radius];
    [self saveAnnotation:geoTag withAnnotation:annotation];
}

#pragma mark - Utility methods
- (void)dropAnnotation
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.mapViewGeofence.centerCoordinate;
    annotation.title = @"Set Title";
    [self.mapViewGeofence addAnnotation:annotation];
}

- (void)setAnnotationView:(MKPinAnnotationView *)annotationView
{
    annotationView.draggable = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
}

- (void)setGeoFence:(MKPointAnnotation *)annotation withRadius:(double)radius
{
    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter:annotation.coordinate
                                   radius:radius
                                   identifier:annotation.title];
    geoRegion.notifyOnEntry = YES;
    geoRegion.notifyOnExit = YES;
    [self.locationManager startMonitoringForRegion:geoRegion];
    [self setupUIGeoRegion:annotation withRadius:radius];
}

- (void)setupUIGeoRegion:(MKPointAnnotation *)annotation withRadius:(double)radius
{
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:radius];
    [self.mapViewGeofence addOverlay:circle];
}

- (void)saveAnnotation:(GeoTag *)geoTag withAnnotation:(MKPointAnnotation *)annotation
{
    geoTag.latitude = annotation.coordinate.latitude;
    geoTag.longitude = annotation.coordinate.longitude;
    [self.geoCoreDataModel saveGeoFenceData:geoTag];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
