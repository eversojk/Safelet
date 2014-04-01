//
//  searchViewController.h
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#import "bluetoothHandler.h"

@interface searchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *passwd;
@property (weak, nonatomic) IBOutlet UITextField *user;

@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (strong) CBCentralManager *manager;
@property (strong) NSMutableDictionary *devices;
@property (strong) UIActivityIndicatorView *activityView;
@property NSString *nextView;
@property NSMutableData *responseData;

- (IBAction) buttonPress:(id) sender;
@end
