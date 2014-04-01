//
//  data.m
//  Safelet
//
//  Created by John Eversole on 4/1/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "data.h"

@implementation data

+ (void) saveLogin:(NSString *)user cookie:(NSString *)cookie
{
    [[NSUserDefaults standardUserDefaults]
     setObject:user forKey:@"user"];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:cookie forKey:@"cookie"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSMutableDictionary *) loadLogin
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"])
    {
        [data setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] forKey:@"user"];
        [data setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"] forKey:@"cookie"];
    } else {
        [data setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@""] forKey:@"user"];
        [data setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@""] forKey:@"cookie"];
    }
    return data;
}

@end
