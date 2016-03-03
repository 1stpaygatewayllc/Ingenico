//
//  UtilityRoutines.h
//  TestApp
//
//  Created by Khalid Khan on 3/17/15.
//  Copyright (c) 2015 KhalidKhan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityRoutines : NSObject

+ (NSString *) stringToHex:(NSString *)str;
+(char) calculateLRC:(NSString *) text;
+(NSData*) hexToBytes:(NSString *) hexaStr;

@end