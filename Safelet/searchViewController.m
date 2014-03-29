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
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    devices = [[NSMutableDictionary alloc] init];
    // create activity spinner
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
    [self.view addSubview:activityView];
}

- (IBAction) buttonPress:(id) sender
{
    // only scan if bluetooth manager is ready
    if (self.ready) {
        [manager scanForPeripheralsWithServices:nil options:nil];
        [activityView startAnimating];
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
    // get bluetooth device name
    NSString *name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    NSLog(@"Found");
    // make sure it's giving us a name
    if (name != nil) {
        [devices setObject:aPeripheral forKey:[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }
    
    // if it's sensortag, stop scanning
    if ([name isEqualToString:@"SensorTag"]) {
        [self stopBTScan];
        [activityView stopAnimating];
        deviceListViewController *new = [[deviceListViewController alloc] initWithNibName:@"deviceListViewController" bundle:nil];
        new.manager = manager;
        new.devices = devices;
        [self.navigationController pushViewController:new animated:YES];
        NSLog(@"Done");
    }
}

@end
