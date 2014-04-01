//
//  newAccountViewController.h
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#import "data.h"
#import "deviceListViewController.h"
#import "loggedinViewController.h"
#import "json.h"

@interface newAccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UITextField *passwd;
@property (weak, nonatomic) IBOutlet UITextField *uname;
@property (weak, nonatomic) IBOutlet UITextField *lname;
@property (weak, nonatomic) IBOutlet UITextField *fname;
@property (strong) CBCentralManager *manager;
@property UIActivityIndicatorView *activity;
@property CBPeripheral *sensorTag;
@property NSMutableData *responseData;

-(NSString *) sha1:(NSString *)input;
-(BOOL) checkInputs:(NSString *)fname lname:(NSString *)lname user:(NSString *)user pass:(NSString *)pass;
-(void) createPopup:(NSString *)title msg:(NSString *)msg;

@end
