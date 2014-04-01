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

- (IBAction) buttonPress:(id) sender
{
    NSString *selected = [self.gender titleForSegmentAtIndex:self.gender.selectedSegmentIndex];
    NSString *sex = @"f";
    
    if ([selected isEqualToString:@"Male"]) {
        sex = @"m";
    }
    
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
    
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"Error: %@", [myError description]);
    
    for(id key in res) {
        id value = [res objectForKey:key];
        
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"key: %@", keyAsString);
        NSLog(@"value: %@", valueAsString);
    }
    
    /*
    NSArray *results = [res objectForKey:@"results"];
    for (NSDictionary *result in results) {
        NSString *icon = [result objectForKey:@"icon"];
        NSLog(@"icon: %@", icon);
    }
    */
}

- (IBAction)doneEditing:(id)sender {
    [sender endEditing:YES];
}

@end