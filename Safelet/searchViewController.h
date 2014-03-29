//
//  searchViewController.h
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface searchViewController : UIViewController
@property (strong) CBCentralManager *manager;
@property (strong) NSMutableDictionary *devices;
@property (strong) UIActivityIndicatorView *activityView;

- (IBAction) buttonPress:(id) sender;
@end
