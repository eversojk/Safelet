//
//  deviceListViewController.h
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface deviceListViewController : UIViewController

@property (nonatomic) CBCentralManager *manager;
@property (nonatomic) NSMutableDictionary *devices;

@end
