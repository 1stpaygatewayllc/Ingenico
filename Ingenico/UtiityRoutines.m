
//
//  UtiityRoutines.m
//  TestApp
//
//  Created by Khalid Khan on 3/17/15.
//  Copyright (c) 2015 KhalidKhan. All rights reserved.
//

#import "UtilityRoutines.h"

@implementation UtilityRoutines

+ (NSString *) stringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendFormat:@"%02x", chars[i]];
    }
    free(chars);
    //[hexString appendString:@"03"];
    
    return hexString;
}

+(char) calculateLRC:(NSString *) text
{
    NSData * data = [self hexToBytes:text];
    
    NSUInteger size = [data length] / sizeof(const char);
    const char * array = (const char*) [data bytes];
    
    char lrc = 0;
    
    for( uint32_t i = 0 ; i < size; i++)
    {
        lrc ^= * array++;
    }
    NSLog(@"LRC = %c", lrc);
    
    return lrc;
}

+ (NSData*) hexToBytes:(NSString *) hexaStr
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexaStr.length; idx+=2)
    {
        NSRange range = NSMakeRange(idx, 2);
        NSString * hexStrTmp = [hexaStr substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStrTmp];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

@end
