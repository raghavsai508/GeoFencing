//
//  GeoTag.h
//  GeoFencing
//
//  Created by Raghav Sai Cheedalla on 10/4/15.
//  Copyright © 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoTag : NSObject

@property (nonatomic, assign) NSInteger             geoTagID;
@property (nonatomic, strong) NSString              *geoTagTitle;
@property (nonatomic, assign) float                 radius;
@property (nonatomic, strong) NSString              *geoTagColor;
@property (nonatomic, strong) NSDate                *geoTagDateCreated;
@property (nonatomic, assign) double                latitude;
@property (nonatomic, assign) double                longitude;

@end
