//
//  deviceListViewController.m
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "deviceListViewController.h"

@interface deviceListViewController ()
@end

@implementation deviceListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.devices = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.activity];
    [self.manager setDelegate:self];
    self.simpleKeys = [CBUUID UUIDWithString:@"ffe0"];
    self.simpleKeysChar = [CBUUID UUIDWithString:@"ffe1"];
    NSLog(@"Devices: %@", self.devices);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count: %d", [self.devices count]);
    return [self.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    // bad way to do this!
    int loc = 0;
    for (id key in self.devices) {
        if (loc == indexPath.row) {
            cell.textLabel.text = key;
        }
        loc++;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Device" message:[NSString stringWithFormat:@"Are you sure you want to connect to %@?", cell.textLabel.text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
    // save user selection
    self.selection = cell.textLabel.text;
    [messageAlert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ok
    if (buttonIndex == 0) {
        [self.activity startAnimating];
        CBPeripheral *sensortag = [self.devices objectForKey:self.selection];
        [self.manager connectPeripheral:sensortag options:nil];
        self.sensorTag = sensortag;
    }
    // cancel
    else if (buttonIndex == 1) {
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"Connected to SensorTag");
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    [self.activity stopAnimating];
    self.sensorTag = aPeripheral;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Account" message:[NSString stringWithFormat:@"Sucessfully connected!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    if ([self.previous isEqualToString:@"new"]) {
        newAccountViewController *x = [[newAccountViewController alloc] initWithNibName:@"newAccountViewController" bundle:nil];
        x.activity = self.activity;
        x.sensorTag = self.sensorTag;
        x.manager = self.manager;
        [self.navigationController pushViewController:x animated:YES];
    } else {
        loggedinViewController *x = [[loggedinViewController alloc] initWithNibName:@"loggedinViewController" bundle:nil];
        x.activity = self.activity;
        x.sensorTag = self.sensorTag;
        x.manager = self.manager;
        [self.navigationController pushViewController:x animated:YES];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed, all hope is lost");
    NSLog(@"Error: %@", error);
    [self.activity stopAnimating];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Discovered services");
    for (CBService *s in aPeripheral.services) {
        if ([s.UUID isEqual:self.simpleKeys]) {
            NSLog(@"Found simpleKeys");
            [self.sensorTag discoverCharacteristics:nil forService:s];
        }
    }
    NSLog(@"Finished discovering services");
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
                [self.sensorTag setNotifyValue:YES forCharacteristic:c];
            }
        }
        NSLog(@"Ready for use");
    }
}
@end
