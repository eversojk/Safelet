//
//  deviceListViewController.h
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#import "newAccountViewController.h"

@interface deviceListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property NSString *selection;
@property UITableView *tableView;
@property UIActivityIndicatorView *activity;
@property CBCentralManager *manager;
@property NSMutableDictionary *devices;
@property CBPeripheral *sensorTag;
@property NSString *previous;

@property CBUUID *simpleKeys;
@property CBUUID *simpleKeysChar;


@end
