//
//  loggedinViewController.h
//  Safelet
//
//  Created by John Eversole on 4/1/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface loggedinViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *waitingShadow;
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet UIButton *testBtn;
@property (strong) CBCentralManager *manager;
@property CBUUID *simpleKeys;
@property CBUUID *simpleKeysChar;
@property UIActivityIndicatorView *activity;
@property CBPeripheral *sensorTag;
@property BOOL test;
@property NSMutableData *responseData;
@property CLGeocoder *gc;
@property CLLocation *currentLoc;
@property CLLocationManager *locManager;
@property CLPlacemark *placemark;

- (IBAction) buttonPress:(id) sender;
@end
