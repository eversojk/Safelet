//
//  newAccountViewController.m
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "newAccountViewController.h"

@interface newAccountViewController ()

@end

@implementation newAccountViewController

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
    self.responseData = [NSMutableData alloc];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

-(void) createPopup:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [messageAlert show];
}

-(BOOL) checkInputs:(NSString*)fname lname:(NSString *)lname user:(NSString *)user pass:(NSString *)pass;
{
    if ([fname length] == 0) {
        [self createPopup:@"Login" msg:@"First name is required."];
        return NO;
    } else if ([lname length] == 0) {
        [self createPopup:@"Login" msg:@"Last name is required."];
        return NO;
    } else if ([user length] == 0) {
        [self createPopup:@"Login" msg:@"Username is required."];
       return NO;
    } else if ([pass length] == 0) {
        [self createPopup:@"Login" msg:@"Password is required."];
        return NO;
    }
    return YES;
}

- (IBAction) buttonPress:(id) sender
{
    NSString *selected = [self.gender titleForSegmentAtIndex:self.gender.selectedSegmentIndex];
    NSString *sex = @"f";
    
    if ([selected isEqualToString:@"Male"]) {
        sex = @"m";
    }
    
    if ([self checkInputs:self.fname.text lname:self.lname.text user:self.uname.text pass:self.passwd.text]) {
        NSString *salt = @"lalalalal";
        NSString *salted = [NSString stringWithFormat:@"%@%@",self.passwd.text, salt];
        NSString *hash = [self sha1:salted];
        NSDictionary *jsonObj = [NSDictionary dictionaryWithObjectsAndKeys:self.fname.text, @"fname", self.lname.text, @"lname", self.uname.text, @"user", hash, @"pass", sex, @"gender", nil];
    
        NSString *jsonStr = [json dictToJson:jsonObj];
        NSLog(@"jsonStr: %@", jsonStr);
        
        // creating post data and url
        NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        //NSString *link = @"http://10.52.105.252:8080/api/create_user";
        NSString *link = @"http://192.168.1.126:8080/api/create_user";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", link]];
        
        NSMutableURLRequest *request = [json requestFromData:url type:@"POST" data:postData contentType:@"application/json charset=utf-8"];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
    }
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
        NSLog(@"cookie from server: %@", [res objectForKey:@"cookie"]);
        [data saveLogin:self.fname.text cookie:[res objectForKey:@"cookie"]];
        NSLog(@"loading saved data");
        NSMutableDictionary *a = [data loadLogin];
        NSLog(@"saved user: %@", [a objectForKey:@"user"]);
        NSLog(@"saved cookie: %@", [a objectForKey:@"cookie"]);
        loggedinViewController *x = [[loggedinViewController alloc] initWithNibName:@"loggedinViewController" bundle:nil];
        x.activity = self.activity;
        x.sensorTag = self.sensorTag;
        [self.navigationController pushViewController:x animated:YES];
    } else {
        [self createPopup:@"Error" msg:err];
    }
    
}

- (IBAction)doneEditing:(id)sender {
    [sender endEditing:YES];
}

@end