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
    // existing account
    if ((UIButton *) sender == self.btn1) {
        self.nextView = @"old";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:[NSString stringWithFormat:@"Make sure your Safelet is discoverable before continuing."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    // new account
    } else {
        self.nextView = @"new";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Account" message:[NSString stringWithFormat:@"The first step of a new account is to find your Safelet. Make sure it is discoverable."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
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
        
        if ([self.nextView isEqualToString:@"new"]) {
            deviceListViewController *v = [[deviceListViewController alloc] initWithNibName:@"deviceListViewController" bundle:nil];
            v.manager = self.manager;
            v.devices = self.devices;
            v.activity = self.activityView;
            v.previous = @"new";
            [self.navigationController pushViewController:v animated:YES];
        } else {
           deviceListViewController *v = [[deviceListViewController alloc] initWithNibName:@"deviceListViewController" bundle:nil];
            v.manager = self.manager;
            v.devices = self.devices;
            v.activity = self.activityView;
            v.previous = @"old";
            [self.navigationController pushViewController:v animated:YES];
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"There was an error in didUpdateValueForCharacteristic");
    }
    
    NSLog(@"updated value here?!");
    CBUUID *simpleKeys = [CBUUID UUIDWithString:@"ffe0"];
    CBUUID *simpleKeysChar = [CBUUID UUIDWithString:@"ffe1"];
    if ([characteristic.UUID isEqual:simpleKeysChar]) {
        uint8_t *ptr = (uint8_t *)[characteristic.value bytes];
        if (ptr) {
            uint8_t location = ptr[0];
            switch (location) {
                case 1:
                    NSLog(@"Right button was pressed");
                    break;
                case 2:
                    NSLog(@"Left button was pressed");
                    break;
                default:
                    NSLog(@"Button was released");
                    break;
            }
        }
    }
}
@end
