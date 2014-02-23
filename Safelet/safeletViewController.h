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
    
    CLGeocoder *gc;
    CLLocation *currentLoc;
    CLLocationManager *locManager;
    CLPlacemark *placemark;
    bool checkLoc;
    
    UIButton *button;
    UILabel *latTitle;
    UILabel *latValue;
    UILabel *longTitle;
    UILabel *longValue;
    UILabel *addressTitle;
    UILabel *addressValue;
}

- (void) dealloc;
- (IBAction) buttonPress:(id) sender;
- (void) stopBTScan;
@end
