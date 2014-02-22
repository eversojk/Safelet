//
//  safeletAppDelegate.m
//  Safelet
//
//  Created by John Eversole on 2/22/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "safeletAppDelegate.h"

@implementation safeletAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    simpleKeys = [CBUUID UUIDWithString:@"ffe0"];
    simpleKeysChar = [CBUUID UUIDWithString:@"ffe1"];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) dealloc
{
    [self stopScan];
}

- (void) startScan
{
    [manager scanForPeripheralsWithServices:nil options:nil];
}

- (void) stopScan
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
        [self stopScan];
        peripheral = aPeripheral;
        [manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        [self startScan];
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
        //NSLog(@"UUID: %@", s.UUID);
        if ([s.UUID isEqual:simpleKeys]) {
            NSLog(@"Found simpleKeys");
            [aPeripheral discoverCharacteristics:nil forService:s];
        }
        //NSLog(@"Same: %@ \n", sameUUID ? @"YES" : @"NO");
    }
    //NSLog(@"Finished discovering services");
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
        NSLog(@"Finished searching");
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
                    break;
                default:
                    NSLog(@"Button was released");
                    break;
            }
        }
    }
}

@end