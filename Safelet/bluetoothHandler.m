//
//  bluetoothHandler.m
//  Safelet
//
//  Created by John Eversole on 4/1/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "bluetoothHandler.h"

@implementation bluetoothHandler

-(id)init {
    self = [super init];
    
    self.manager = [CBCentralManager alloc];
    self.sensorTag = [CBPeripheral alloc];
    self.simpleKeys = [CBUUID alloc];
    self.simpleKeys = [CBUUID UUIDWithString:@"ffe0"];
    self.simpleKeysChar = [CBUUID alloc];
    self.simpleKeysChar = [CBUUID UUIDWithString:@"ffe1"];
    
    return self;
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
    NSLog(@"TEST TEST");
    if ([[advertisementData objectForKey:@"kCBAdvDataLocalName"] isEqualToString:@"SensorTag"]) {
        NSLog(@"Found SensorTag");
        //[button setTitle:@"Found SensorTag" forState:UIControlStateNormal];
        [central stopScan];
        self.sensorTag = aPeripheral;
        [central connectPeripheral:self.sensorTag options:nil];
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"testConnected to SensorTag");
    self.sensorTag = aPeripheral;
    [self.sensorTag setDelegate:self];
    [self.sensorTag discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Discovered services");
    for (CBService *s in aPeripheral.services) {
        if ([s.UUID isEqual:self.simpleKeys]) {
            NSLog(@"Found simpleKeys");
            self.sensorTag = aPeripheral;
            [self.sensorTag discoverCharacteristics:nil forService:s];
        }
    }
    NSLog(@"testFinished discovering services");
    //[button setTitle:@"Connected" forState:UIControlStateNormal];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   if (error) {
       NSLog(@"There was an error in didDiscoverCharacteristicsForService");
   }
    
    if ([service.UUID isEqual:self.simpleKeys]) {
        NSLog(@"testSearching for characteristics");
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID isEqual:self.simpleKeysChar]) {
                NSLog(@"testFound simpleykeys characteristics");
                self.sensorTag = aPeripheral;
                [self.sensorTag setNotifyValue:YES forCharacteristic:c];
            }
        }
        NSLog(@"Ready for use");
        //[button setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
}
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"There was an error in didUpdateValueForCharacteristic");
    }
    NSLog(@"MAUBE test");
    
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
@end