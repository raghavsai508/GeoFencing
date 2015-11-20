//
//  GeoCoreDataModel.m
//  GeoFencing
//
//  Created by Raghav Sai Cheedalla on 10/7/15.
//  Copyright © 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "GeoCoreDataModel.h"
#import "GeoContainer.h"
#import "GeoTag.h"

@interface GeoCoreDataModel ()

@property (nonatomic, strong) NSManagedObjectContext                  *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel                    *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator            *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;


@end

@implementation GeoCoreDataModel

/* This method returns a singlet instance. */
+ (instancetype)coreDataDefaultManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)saveGeoFenceData:(id)geoTag
{
    NSManagedObject *managedObject = [self getManagedObject];
    GeoTag *geoTagObject = (GeoTag *)geoTag;
    [managedObject setValue:[NSNumber numberWithInteger:geoTagObject.geoTagID] forKey:@"tagID"];
    [managedObject setValue:geoTagObject.geoTagTitle forKey:@"title"];
    [managedObject setValue:[NSNumber numberWithDouble:geoTagObject.radius] forKey:@"radius"];
    [managedObject setValue:[NSNumber numberWithDouble:geoTagObject.latitude] forKey:@"lat"];
    [managedObject setValue:[NSNumber numberWithDouble:geoTagObject.longitude] forKey:@"long"];
    [managedObject setValue:geoTagObject.geoTagColor forKey:@"color"];
    [managedObject setValue:geoTagObject.geoTagDateCreated forKey:@"dateCreated"];
    [self saveManagedObject:managedObject];
}

- (id)getGeoFenceData
{
    NSArray *geoArray = [self fetchGeoData];
    GeoContainer *geoContainer = [self getGeoContainer:geoArray];
    return geoContainer;
}

#pragma mark - Helper methods
- (NSManagedObject *)getManagedObject
{
    NSEntityDescription *enityDescription = [NSEntityDescription entityForName:@"GeoTag" inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *managedObject = [[NSManagedObject alloc] initWithEntity:enityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    return managedObject;
}

- (NSArray *)fetchGeoData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GeoTag" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error)
    {
        NSLog(@"unable to fetch request %@, %@",error,error.localizedDescription);
        return nil;
    }
    else
        return result;
}

- (GeoContainer *)getGeoContainer:(NSArray *)geoArray
{
    GeoContainer *geoContainer = [[GeoContainer alloc] init];
    geoContainer.geoContainerArray = [self parseArray:geoArray];
    return geoContainer;
}

- (NSArray *)parseArray:(NSArray *)geoArray
{
    NSMutableArray *tempGeoArray = [[NSMutableArray alloc] init];
    for(NSManagedObject *geoManagedObject in geoArray)
    {
        GeoTag *geoTag = [[GeoTag alloc] init];
        geoTag.geoTagID = [[geoManagedObject valueForKey:@"tagID"] intValue];
        geoTag.geoTagTitle = [geoManagedObject valueForKey:@"title"];
        geoTag.radius = [[geoManagedObject valueForKey:@"radius"] doubleValue];
        geoTag.latitude = [[geoManagedObject valueForKey:@"lat"] doubleValue];
        geoTag.longitude = [[geoManagedObject valueForKey:@"long"] doubleValue];
        geoTag.geoTagColor = [geoManagedObject valueForKey:@"color"];
        geoTag.geoTagDateCreated = [geoManagedObject valueForKey:@"dateCreated"];
        [tempGeoArray addObject:geoTag];
    }
    return tempGeoArray;
}

- (void)saveManagedObject:(NSManagedObject *)managedObject
{
    NSError *error = nil;
    if(![managedObject.managedObjectContext save:&error])
    {
        NSLog(@"Unable to save managed object context");
        NSLog(@"%@ ,%@",error,error.localizedDescription);
    }
}

#pragma mark - CoreData stack
- (NSManagedObjectContext *)managedObjectContext
{
    if(_managedObjectContext!=nil)
        return _managedObjectContext;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator!=nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if(_managedObjectModel!=nil)
        return _managedObjectModel;
    NSURL *pathForModel = [[NSBundle mainBundle] URLForResource:@"GeoFence" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:pathForModel];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if(_persistentStoreCoordinator!=nil)
        return _persistentStoreCoordinator;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GeoFence.sqlite"];
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved Error: %@, %@",error,[error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
