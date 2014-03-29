//
//  newAccountViewController.h
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#import "deviceListViewController.h"

@interface newAccountViewController : UIViewController

@property UIActivityIndicatorView *activity;
@property CBPeripheral *sensorTag;

@end
