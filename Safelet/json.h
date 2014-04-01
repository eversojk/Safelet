//
//  json.h
//  Safelet
//
//  Created by John Eversole on 3/31/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface json : NSObject

+ (NSMutableURLRequest *) requestFromData:(NSURL *)link type:(NSString *)type data:(NSData *)data contentType:(NSString *)cT;
+ (NSString *) dictToJson:(NSDictionary *)dict;

@end