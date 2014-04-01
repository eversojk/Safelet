//
//  loggedinViewController.m
//  Safelet
//
//  Created by John Eversole on 4/1/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "loggedinViewController.h"

@interface loggedinViewController ()

@end

@implementation loggedinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.waitingLabel.hidden = YES;
    self.waitingShadow.hidden = YES;
    [self.manager setDelegate:self];
    [self.sensorTag setDelegate:self];
    self.simpleKeys = [CBUUID UUIDWithString:@"ffe0"];
    self.simpleKeysChar = [CBUUID UUIDWithString:@"ffe1"];
    [self.manager cancelPeripheralConnection:self.sensorTag];
    [self.manager connectPeripheral:self.sensorTag options:nil];
}

- (void)showWait
{
    self.waitingShadow.hidden = NO;
    self.waitingLabel.hidden = NO;
    [self.activity startAnimating];
    NSLog(@"%@", self.manager);
    NSLog(@"%@", self.sensorTag);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) buttonPress:(id) sender;
{
    if (sender == self.testBtn) {
        NSLog(@"test connection button was hit");
        [self showWait];
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"There was an error in didUpdateValueForCharacteristic");
    }
    
    if ([characteristic.UUID isEqual:self.simpleKeysChar]) {
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
        if ([s.UUID isEqual:self.simpleKeys]) {
            NSLog(@"Found simpleKeys");
            [aPeripheral discoverCharacteristics:nil forService:s];
        }
    }
    NSLog(@"Finished discovering services");
    //[button setTitle:@"Connected" forState:UIControlStateNormal];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   if (error) {
       NSLog(@"There was an error in didDiscoverCharacteristicsForService");
   }
    
    if ([service.UUID isEqual:self.simpleKeys]) {
        NSLog(@"Searching for characteristics");
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID isEqual:self.simpleKeysChar]) {
                NSLog(@"Found simpleykeys characteristics");
                [aPeripheral setNotifyValue:YES forCharacteristic:c];
            }
        }
        NSLog(@"Ready for use");
    }
}
@end
