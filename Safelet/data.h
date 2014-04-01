//
//  data.h
//  Safelet
//
//  Created by John Eversole on 4/1/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface data : NSObject

+ (void) saveLogin:(NSString *)user cookie:(NSString *)cookie;
+ (NSMutableDictionary *) loadLogin;

@end
