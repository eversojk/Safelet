//
//  loggedinViewController.m
//  Safelet
//
//  Created by John Eversole on 4/1/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "loggedinViewController.h"
#import "json.h"

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
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.responseData = [NSMutableData alloc];
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
        self.test = YES;
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
                    if (self.test) {
                        NSLog(@"right test");
                        self.waitingShadow.hidden = YES;
                        self.waitingLabel.hidden = YES;
                        [self.activity stopAnimating];
                        self.test = NO;
                    } else {
                        NSLog(@"right real");
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        [self.locManager startUpdatingLocation];
                    }
                    break;
                case 2:
                    if (self.test) {
                        NSLog(@"left test");
                        self.waitingShadow.hidden = YES;
                        self.waitingLabel.hidden = YES;
                        [self.activity stopAnimating];
                        self.test = NO;
                    } else {
                        NSLog(@"left real");
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        [self.locManager startUpdatingLocation];
                    }
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *loc = newLocation;
    //currentLoc = newLocation;
    //[latValue setText:[NSString stringWithFormat:@"%f", currentLoc.coordinate.latitude]];
    //[longValue setText:[NSString stringWithFormat:@"%f", currentLoc.coordinate.longitude]];
    
    NSMutableDictionary *log =[[NSMutableDictionary alloc] init];
    NSLog(@"jsondict: %@", log);
    [log setObject:[NSNumber numberWithDouble:loc.coordinate.latitude] forKey:@"lat"];
    [log setObject:[NSNumber numberWithDouble:loc.coordinate.longitude] forKey:@"long"];
    [log setObject:@"user" forKey:@"user"];
    
    NSString *jsonStr = [json dictToJson:log];
    NSLog(@"jsonStr: %@", jsonStr);
    
    // creating post data and url
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *link = @"http://10.52.105.252:8080/api/log";
    NSString *link = @"http://192.168.1.126:8080/api/log";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", link]];
        
    NSMutableURLRequest *request = [json requestFromData:url type:@"POST" data:postData contentType:@"application/json charset=utf-8"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
    [self.locManager stopUpdatingLocation];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Received a response");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Adding data");
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %d bytes of data", [self.responseData length]);
    
    NSError *error = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"Error: %@", [error description]);
    
    NSString *err = [res objectForKey:@"error"];
    if ([err length] == 0) {
        NSLog(@"no error from server");
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    } else {
        NSLog(@"log error");
    }
    
}
@end
