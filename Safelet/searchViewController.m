//
//  searchViewController.m
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "searchViewController.h"

@interface searchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UILabel *device;
@property BOOL ready;
@end

@implementation searchViewController
NSMutableDictionary *devices;
UIActivityIndicatorView *activityView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    simpleKeys = [CBUUID UUIDWithString:@"ffe0"];
    simpleKeysChar = [CBUUID UUIDWithString:@"ffe1"];
    devices = [[NSMutableDictionary alloc] init];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
    [self.view addSubview:activityView];
}

- (IBAction) buttonPress:(id) sender
{
    if (self.ready) {
        [manager scanForPeripheralsWithServices:nil options:nil];
        [activityView startAnimating];
    } else {
        NSLog(@"NOT READY");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        self.ready = YES;
    }
}

- (void) stopBTScan
{
    [manager stopScan];
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    /*
     advertisement data for the sensortag
     kCBAdvDataChannel: 39
     kCBAdvDataIsConnectable: 1
     kCBAdvDataLocalName: SensorTag
     kCBAdvDataTxPowerLevel: 0
     */
    NSString *name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    if (name != nil) {
        [devices setObject:aPeripheral forKey:[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }
    
    if ([name isEqualToString:@"SensorTag"]) {
        NSLog(@"Made it");
        [self stopBTScan];
        [activityView stopAnimating];
    }
}
@end