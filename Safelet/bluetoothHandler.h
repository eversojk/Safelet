//
//  bluetoothHandler.h
//  Safelet
//
//  Created by John Eversole on 4/1/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "searchViewController.h"

@interface bluetoothHandler : NSObject

@property CBCentralManager *manager;
@property CBPeripheral *sensorTag;
@property CBUUID *simpleKeys;
@property CBUUID *simpleKeysChar;

-(id) init;
@end