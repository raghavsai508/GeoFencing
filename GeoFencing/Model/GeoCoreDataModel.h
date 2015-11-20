//
//  GeoCoreDataModel.h
//  GeoFencing
//
//  Created by Raghav Sai Cheedalla on 10/7/15.
//  Copyright © 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoCoreDataModel : NSObject

+ (instancetype)coreDataDefaultManager;

- (id)getGeoFenceData;
- (void)saveGeoFenceData:(id)geoTag;

@end
