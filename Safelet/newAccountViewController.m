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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
                             
    NSLog(@"json: %@", jsonObj);
}

- (IBAction)doneEditing:(id)sender {
    
    [sender endEditing:YES];
}
@end
