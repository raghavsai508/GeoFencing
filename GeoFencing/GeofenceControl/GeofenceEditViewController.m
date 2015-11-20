//
//  GeofenceEditViewController.m
//  GeoFencing
//
//  Created by Raghav Sai Cheedalla on 10/4/15.
//  Copyright © 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "GeofenceEditViewController.h"
#import "GeoTag.h"

@interface GeofenceEditViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField            *txtGeofenceTitle;
@property (weak, nonatomic) IBOutlet UISlider               *sliRadius;
@property (weak, nonatomic) IBOutlet UILabel                *lblRadiusValue;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *segColorControl;
@property (weak, nonatomic) IBOutlet UIButton               *btnGeofence;

@end

@implementation GeofenceEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialSetup];
}

- (void)initialSetup
{
    self.btnGeofence.enabled = NO;
    [self setupNavLeftBarButton];
    [self setDelegates];
}

- (void)setupNavLeftBarButton
{
    UIBarButtonItem *leftCancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelGeofence)];
    self.navigationItem.leftBarButtonItem = leftCancelBarButton;
}

- (void)setDelegates
{
    self.txtGeofenceTitle.delegate = self;
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = textField.text.length + string.length - range.length;
    if(newLength > 0)
        self.btnGeofence.enabled = YES;
    else
        self.btnGeofence.enabled = NO;
    
    return YES;
}


#pragma mark - Action methods
- (IBAction)radiusChanged:(UISlider *)sender
{
    self.lblRadiusValue.text =[NSString stringWithFormat:@"%f",sender.value];
}

- (IBAction)addGeofence:(id)sender
{
    GeoTag *geoTag = [self getGeoTag];
    [self.geofenceDelegate addGeofence:geoTag];
    [self dismissController];
}

- (void)cancelGeofence
{
    [self dismissController];
}

#pragma mark - utility methods
- (void)dismissController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (GeoTag *)getGeoTag
{
    GeoTag *tempGeoTag = [[GeoTag alloc] init];
    tempGeoTag.geoTagTitle = self.txtGeofenceTitle.text;
    tempGeoTag.geoTagColor = [self.segColorControl titleForSegmentAtIndex:[self.segColorControl selectedSegmentIndex]];
    tempGeoTag.radius = self.sliRadius.value/3.28084;
    tempGeoTag.geoTagID = self.annotationIndex;
    tempGeoTag.geoTagDateCreated = [NSDate date];
    return tempGeoTag;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
