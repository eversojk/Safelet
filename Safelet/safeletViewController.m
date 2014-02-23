//
//  safeletViewController.m
//  Safelet
//
//  Created by John Eversole on 2/22/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "safeletViewController.h"

@interface safeletViewController ()
@end

@implementation safeletViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    simpleKeys = [CBUUID UUIDWithString:@"ffe0"];
    simpleKeysChar = [CBUUID UUIDWithString:@"ffe1"];
    
    checkLoc = true;
    locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;
    locManager.desiredAccuracy = kCLLocationAccuracyBest;
    gc = [[CLGeocoder alloc] init];
    
    latTitle = [[UILabel alloc]initWithFrame:CGRectMake(75, 100, 200, 40)];
    [latTitle setBackgroundColor:[UIColor clearColor]];
    [latTitle setText:@"Lat:"];
    [[self view] addSubview:latTitle];
    
    latValue = [[UILabel alloc]initWithFrame:CGRectMake(120, 100, 300, 40)];
    [latValue setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:latValue];
    
    longTitle = [[UILabel alloc]initWithFrame:CGRectMake(60, 120, 200, 40)];
    [longTitle setBackgroundColor:[UIColor clearColor]];
    [longTitle setText:@"Long:"];
    [[self view] addSubview:longTitle];
    
    longValue = [[UILabel alloc]initWithFrame:CGRectMake(120, 120, 300, 40)];
    [longValue setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:longValue];
    
    addressTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 140, 200, 40)];
    [addressTitle setBackgroundColor:[UIColor clearColor]];
    [addressTitle setText:@"Address:"];
    [[self view] addSubview:addressTitle];
    
    addressValue = [[UILabel alloc]initWithFrame:CGRectMake(120, 130, 300, 100)];
    [addressValue setNumberOfLines:0];
    [addressValue setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:addressValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [self stopBTScan];
}

- (IBAction) buttonPress:(id) sender
{
    button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"Disconnect"]) {
        [manager cancelPeripheralConnection:peripheral];
        [button setTitle:@"Connect" forState:UIControlStateNormal];
    }
    else if ([button.titleLabel.text isEqualToString:@"Connect"]) {
        [button setTitle:@"Searching..." forState:UIControlStateNormal];
        [manager scanForPeripheralsWithServices:nil options:nil];
    }
    else {
        NSLog(@"NOTHIN!");
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
    if ([[advertisementData objectForKey:@"kCBAdvDataLocalName"] isEqualToString:@"SensorTag"]) {
        NSLog(@"Found SensorTag");
        [button setTitle:@"Found SensorTag" forState:UIControlStateNormal];
        [self stopBTScan];
        peripheral = aPeripheral;
        [manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    /*
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        [self startBTScan];
    }
     */
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"Connected to SensorTag");
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Discovered services");
    for (CBService *s in aPeripheral.services) {
        if ([s.UUID isEqual:simpleKeys]) {
            NSLog(@"Found simpleKeys");
            [aPeripheral discoverCharacteristics:nil forService:s];
        }
    }
    NSLog(@"Finished discovering services");
    [button setTitle:@"Connected" forState:UIControlStateNormal];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   if (error) {
       NSLog(@"There was an error in didDiscoverCharacteristicsForService");
   }
    
    if ([service.UUID isEqual:simpleKeys]) {
        NSLog(@"Searching for characteristics");
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID isEqual:simpleKeysChar]) {
                NSLog(@"Found simpleykeys characteristics");
                [peripheral setNotifyValue:YES forCharacteristic:c];
            }
        }
        NSLog(@"Ready for use");
        [button setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
}
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"There was an error in didUpdateValueForCharacteristic");
    }
    
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
                    if (checkLoc) {
                        [locManager startUpdatingLocation];
                    }
                    break;
                default:
                    NSLog(@"Button was released");
                    break;
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLoc = newLocation;
    
    if (currentLoc != nil) {
        [latValue setText:[NSString stringWithFormat:@"%f", currentLoc.coordinate.latitude]];
        [longValue setText:[NSString stringWithFormat:@"%f", currentLoc.coordinate.longitude]];
    }
    
    NSLog(@"Resolving the Address");
    [gc reverseGeocodeLocation:currentLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            [addressValue setText:[NSString stringWithFormat:@"\n %@ %@\n %@, %@ %@\n %@",
                placemark.subThoroughfare, placemark.thoroughfare, placemark.locality,
                placemark.administrativeArea, placemark.postalCode, placemark.country]];
        } else {
            if (error.code == 2) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection could be found." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            NSLog(@"Code: %ld", (long) error.code);
        }
    } ];
    
    // Stop Location Manager
    [locManager stopUpdatingLocation];
}
@end