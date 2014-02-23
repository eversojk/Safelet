//
//  safeletViewController.h
//  Safelet
//
//  Created by John Eversole on 2/22/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface safeletViewController : UIViewController {
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    CBUUID *simpleKeys;
    CBUUID *simpleKeysChar;
    CLLocationManager *locManager;
    CLLocation *currentLoc;
    CLGeocoder *gc;
    CLPlacemark *placemark;
    bool checkLoc;
}

- (void) dealloc;
- (void) startBTScan;
- (void) stopBTScan;
@end
