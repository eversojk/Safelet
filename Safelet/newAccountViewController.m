//
//  newAccountViewController.m
//  Safelet
//
//  Created by John Eversole on 3/29/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

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

- (IBAction) buttonPress:(id) sender
{
    NSString *selected = [self.gender titleForSegmentAtIndex:self.gender.selectedSegmentIndex];
    if ([selected isEqualToString:@"1"]) {
        NSLog(@"gender is 1");
    } else {
        NSLog(@"gender is 0");
    }
    
    NSDictionary *jsonObj = [NSDictionary dictionaryWithObjectsAndKeys:@"fname", self.fname.text,
                             @"lname", self.lname.text, @"user", self.uname.text, @"pass", self.passwd.text, nil];
                             
    NSLog(@"json: %@", jsonObj);
}

- (IBAction)doneEditing:(id)sender {
    
    [sender endEditing:YES];
}
@end
