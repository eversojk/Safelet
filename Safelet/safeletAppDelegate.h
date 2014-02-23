//
//  safeletAppDelegate.h
//  Safelet
//
//  Created by John Eversole on 2/22/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface safeletAppDelegate : UIResponder <UIApplicationDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    CBUUID *simpleKeys;
    CBUUID *simpleKeysChar;
    CLLocationManager *locManager;
    CLLocation *currentLoc;
    bool checkLoc;
}

@property (strong, nonatomic) UIWindow *window;

- (void) dealloc;
- (void) startScan;
- (void) stopScan;

@end
