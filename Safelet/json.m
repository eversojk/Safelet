//
//  json.m
//  Safelet
//
//  Created by John Eversole on 3/31/14.
//  Copyright (c) 2014 Team Safelet. All rights reserved.
//

#import "json.h"

@implementation json


+ (NSMutableURLRequest*) requestFromData:(NSURL *)link type:(NSString *)type data:(NSData *)data contentType:(NSString *)cT;
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:link];
    [request setHTTPMethod:type];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:cT forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    return request;
}

+ (NSString *) dictToJson:(NSDictionary *)dict;
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

@end
