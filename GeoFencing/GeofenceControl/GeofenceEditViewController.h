//
//  GeofenceEditViewController.h
//  GeoFencing
//
//  Created by Raghav Sai Cheedalla on 10/4/15.
//  Copyright © 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoTag.h"

@protocol GeofencingProtocol <NSObject>

- (void)addGeofence:(GeoTag *)geoTag;

@end

@interface GeofenceEditViewController : UIViewController

@property (nonatomic, assign) NSUInteger                annotationIndex;
@property (nonatomic, weak) id<GeofencingProtocol>      geofenceDelegate;

@end
