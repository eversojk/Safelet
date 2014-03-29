//
//  searchViewController.m
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "deviceListViewController.h"
#import "searchViewController.h"

@interface searchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UILabel *device;
@property BOOL ready;
@end

@implementation searchViewController


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
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.devices = [[NSMutableDictionary alloc] init];
    // create activity spinner
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView.center=self.view.center;
    [self.view addSubview:self.activityView];
}

- (IBAction) buttonPress:(id) sender
{
    // only scan if bluetooth manager is ready
    if (self.ready) {
        [self.manager scanForPeripheralsWithServices:nil options:nil];
        [self.activityView startAnimating];
        NSLog(@"SCANNING");
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
        // mark bluetooth manager as ready
        self.ready = YES;
    }
}

- (void) stopBTScan
{
    [self.manager stopScan];
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
    // get bluetooth device name
    NSString *name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    // make sure it's giving us a name
    if (name != nil) {
        [self.devices setObject:aPeripheral forKey:[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }
    
    // if it's sensortag, stop scanning
    if ([name isEqualToString:@"SensorTag"]) {
        [self stopBTScan];
        [self.activityView stopAnimating];
        deviceListViewController *new = [[deviceListViewController alloc] initWithNibName:@"deviceListViewController" bundle:nil];
        new.manager = self.manager;
        new.devices = self.devices;
        new.activity = self.activityView;
        [self.navigationController pushViewController:new animated:YES];
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"Connected to SensorTag");
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    //[self.activity stopAnimating];
}
@end
