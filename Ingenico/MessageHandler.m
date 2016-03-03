//
//  MessageHandler.m
//  TestApp
//
//  Created by Khalid Khan on 3/19/15.
//  Copyright (c) 2015 KhalidKhan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#import "MessageHandler.h"
#import "UtilityRoutines.h"
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#import "RegExKitLite.h"

@interface MessageHandler (hidden)
- (NSDictionary *) parseTrack1:(NSString *)track1;
- (NSDictionary *) parsetrack2:(NSString *)track2;  //
- (NSDictionary *) parseP2PEdata:(NSString *)p2pestr;
- (NSDictionary *) parseApplePay:(NSString *)data;
@end


@implementation MessageHandler (hidden)

- (NSDictionary *) parseApplePay:(NSString *)data
{
    NSDictionary *applepay = NULL;
    NSRange range = [data rangeOfString:@"@"];
    NSString *transtr1 = [data substringWithRange:NSMakeRange(0, range.location)];
    NSLog (@"Trans string 1: %@", transtr1);
    NSString *str = [data substringFromIndex:range.location+1];
    NSLog(@"str: %@", str);
    
    NSString *transtr2 = [str substringFromIndex:[str rangeOfString:@"@"].location+1];
    NSLog (@"Trans string 2: %@", transtr2);
    
    //NSRange range2 = NSMakeRange (1, [str rangeOfString:@"@"].location-1);
    NSString *track2 = [str substringWithRange:NSMakeRange (1, [str rangeOfString:@"@"].location-1)];
    
    NSString *accountNumber = [track2 substringToIndex:[track2 rangeOfString:@"="].location];
    NSString *expirationDate = [track2 substringWithRange:NSMakeRange([track2 rangeOfString:@"="].location+1, 4)];
    NSRange rangesc = NSMakeRange([track2 rangeOfString:@"="].location+5, 3);
    NSString *serviceCode = [track2 substringWithRange:rangesc];
    NSRange rangepvv = NSMakeRange([track2 rangeOfString:@"="].location+8, 5);
    NSString *pvv = [track2 substringWithRange:rangepvv];
    NSString *discretionaryData = [track2 substringFromIndex:[track2 rangeOfString:@"="].location+13];
    
    applepay = @{
                 @"Track2Data" : track2,
                 @"TransactionString1" : transtr1,
                 @"TransactionString2" : transtr2,
                 @"AccountNumber" : accountNumber,
                 @"ExpirationDate" : expirationDate,
                 @"ServiceCode" : serviceCode,
                 @"PVV" : pvv,
                 @"DiscretionaryData" : discretionaryData,
                 };
    
    return applepay;
    
    
    //return NULL;
}

- (NSDictionary *) parseTrack1:(NSString *)track1
{
    NSDictionary *track1Data = NULL;
    if (track1.length > 0) {
        @try
        {
            // Parse track1 - best way I know thus far...
            NSString *accountNumber = [track1 substringWithRange:NSMakeRange (2, [track1 rangeOfString:@"^"].location-2)];
            NSString *str = [track1 substringFromIndex:[track1 rangeOfString:@"^"].location+1];
            NSString *name = [str substringToIndex:[str rangeOfString:@"^"].location];
            NSString *expirationDate= [str substringWithRange:NSMakeRange([str rangeOfString:@"^"].location+1, 4)];
            NSString *serviceCode = [str substringWithRange:NSMakeRange([str rangeOfString:@"^"].location+5, 3)];
            NSString *discretionaryData = [str substringFromIndex:[str rangeOfString:@"^"].location+8];
            NSString *lastName = @"";
            NSString *firstName = @"";
            if ([name rangeOfString:@"/"].location != NSNotFound) // AMEX
            {
                lastName = [name substringFromIndex:[name rangeOfString:@"/"].location+1];
                firstName = [name substringToIndex:[name rangeOfString:@"/"].location];
            }
            track1Data = @{
                           @"Track1Data" : track1,
                           @"AccountNumber" : accountNumber,
                           @"ExpirationDate" : expirationDate,
                           @"ServiceCode" : serviceCode,
                           @"Name" : name,
                           @"LastName" : lastName,
                           @"FirstName" : firstName,
                           };
        }
        @catch (NSException *e) {
            NSLog(@"NSException in parse track1: %@", e);
            return NULL;
        }
        @finally {
            NSLog(@"FINALLY");
        }
    }
    return track1Data;
}

- (NSDictionary *) parsetrack2:(NSString *)track2
{
    NSDictionary *track2Data = NULL;
    
    if (track2.length > 0)
    {
        @try
        {
            NSString *accountNumber = [track2 substringToIndex:[track2 rangeOfString:@"="].location];
            NSString *expirationDate = [track2 substringWithRange:NSMakeRange([track2 rangeOfString:@"="].location+1, 4)];
            NSRange rangesc = NSMakeRange([track2 rangeOfString:@"="].location+5, 3);
            NSString *serviceCode = [track2 substringWithRange:rangesc];
            NSRange rangepvv = NSMakeRange([track2 rangeOfString:@"="].location+8, 5);
            NSString *pvv = [track2 substringWithRange:rangepvv];
            NSString *discretionaryData = [track2 substringFromIndex:[track2 rangeOfString:@"="].location+13];
            
            track2Data = @{
                           @"Track2Data" : track2,
                           @"AccountNumber" : accountNumber,
                           @"ExpirationDate" : expirationDate,
                           @"ServiceCode" : serviceCode,
                           @"PVV" : pvv,
                           @"DiscretionaryData" : discretionaryData,
                           };
        }
        @catch (NSException *exception) {
            NSLog(@"NSException at parse track2: %@", exception);
        }
        @finally {
            NSLog(@"finally");
        }
    }
    return track2Data;
}

- (NSDictionary *) parseP2PEdata:(NSString *)p2pestr
{
    NSDictionary *p2peData = NULL;
    
    if (p2pestr.length > 0)
    {
        @try
        {
            NSString *ksn= [p2pestr substringToIndex:[p2pestr rangeOfString:@":"].location];
            NSString *encryptedTracks= [p2pestr substringWithRange:NSMakeRange([p2pestr rangeOfString:@":"].location+1, 1)];
            NSRange rangelen = NSMakeRange([p2pestr rangeOfString:@":"].location+3, 4);
            NSString *encryptedDatalength = [p2pestr substringWithRange:rangelen];
            NSString *encryptedData = [p2pestr substringFromIndex:[p2pestr rangeOfString:@":"].location+8];
            
            p2peData = @{
                         @"KSN" : ksn,
                         @"EncryptedTracks" : encryptedTracks,
                         @"EncryptedDataLength" : encryptedDatalength,
                         @"EncryptedData" : encryptedData,
                         };
        }
        @catch (NSException *exception) {
            NSLog(@"NSException at parse p2pe string: %@", exception);
        }
        @finally {
            NSLog(@"finally");
        }
    }
    return p2peData;
}
@end

@implementation MessageHandler

@synthesize inputStream;
@synthesize outputStream;
@synthesize cardData = _cardData;

+(void)initialize
{
    if (self == [MessageHandler class])
    {
        NSLog(@"Inside initialize");
        
    }
}

- (void)broadCast
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //[self listenForPackets];
    });
    
    listeningSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (listeningSocket <= 0) {
        NSLog(@"Error: Could not open socket.");
        return;
    }
    
    // set socket options enable broadcast
    int broadcastEnable = 1;
    int ret = setsockopt(listeningSocket, SOL_SOCKET,SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        NSLog(@"Error: Could not set socket to broadcast mode");
        close(listeningSocket);
        return;
    }
    
    
    
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr;
    memset(&broadcastAddr, 0, sizeof(broadcastAddr));
    broadcastAddr.sin_family = AF_INET;
    broadcastAddr.sin_port = htons(12000);
    broadcastAddr.sin_addr.s_addr = INADDR_ANY;
    int status = bind(listeningSocket, (struct sockaddr *)&broadcastAddr, sizeof(broadcastAddr));
    if(status == -1){
        NSLog(@"bind error %d",errno);
        return;
    }
    else{
        // receive
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            struct sockaddr_in receiveSockaddr;
            socklen_t receiveSockaddrLen = sizeof(receiveSockaddr);
            while(1)
            {
                size_t bufSize = 40000;
                char *buf = malloc(bufSize);
                ssize_t result = recvfrom(listeningSocket, buf, bufSize, 0, (struct sockaddr *)&receiveSockaddr, &receiveSockaddrLen);
                
                NSData *data = nil;
                NSLog(@"LISTEN Result %zd",result);
                if (result > 0) {
                    if ((size_t)result != bufSize) {
                        buf = realloc(buf, result);
                    }
                    data = [NSData dataWithBytesNoCopy:buf length:result freeWhenDone:YES];
                    
                    char addrBuf[INET_ADDRSTRLEN];
                    if (inet_ntop(AF_INET, &receiveSockaddr.sin_addr, addrBuf, (size_t)sizeof(addrBuf)) == NULL) {
                        addrBuf[0] = '\0';
                    }
                    
                    NSString *msg = @"";
                    for(int i = 0;i<result;i++){
                        int c = buf[i];
                        if(isxdigit(c) == NO && c != 0x2E && c!= 0x3A){
                            msg = [msg stringByAppendingFormat:@"|"];
                        }
                        else{
                            msg = [msg stringByAppendingFormat:@"%c",buf[i]];
                        }
                    }
                    
                    
                    NSString *address = [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
                    //NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self didReceiveMessage:msg fromAddress:address];
                    });
                    
                } else {
                    return;
                    //free(buf);
                }
            }
        });
    }
    
    
    inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr);
    char * buf = malloc(7);
    memset(buf, 0, 7);
    //DISCOVERY PACKET
    buf[0] = 0x02;
    buf[1] = 0x35;
    buf[2] = 0x38;
    buf[3] = 0x2E;
    buf[4] = 0x30;
    buf[5] = 0x03;
    buf[6] = 0x10;
    NSLog(@"%s",buf);
    ret = sendto(listeningSocket,buf,strlen(buf), 0, (struct sockaddr*)&broadcastAddr, sizeof(broadcastAddr));
    if (ret < 0) {
        NSLog(@"Error: Could not open send broadcast.");
        close(listeningSocket);
        return;
    }
    
    
}

-(void)sendDiscoveryBroadcast
{
    char buf[7] = {0};
    //DISCOVERY PACKET
    buf[0] = 0x02;
    buf[1] = 0x35;
    buf[2] = 0x38;
    buf[3] = 0x2E;
    buf[4] = 0x30;
    buf[5] = 0x03;
    buf[6] = 0x10;
    NSLog(@"%s",buf);
    int ret = send(listeningSocket, buf, strlen(buf), 0);
    if (ret < 0) {
        NSLog(@"Error: Could not open send broadcast. %d",errno);
    }
    
}



- (void)didReceiveMessage:(NSString *)message fromAddress:(NSString *)address
{
    if([message containsString:@"58.000"]){
        NSMutableArray * ingenicoDetails = [message componentsSeparatedByString:@"|"];
        
        if(ingenicoDetails != nil && ingenicoDetails.count > 0){
            if([ingenicoDetails[3] caseInsensitiveCompare:@"192.168.100.118"] == NSOrderedSame){
                ingenicoIP = ingenicoDetails[3];
                ingenicoMAC = ingenicoDetails[2];
                close(listeningSocket);
                [self connectToIngenico];
                NSLog(@"Ingenico: %@",ingenicoDetails);
            }
        }
        
    }
    NSLog(@"didReceiveMessage: %@ from %@",message,address);
}


- (OSStatus)extractIdentity:(CFDataRef)inP12Data :(SecIdentityRef*)identity {
    OSStatus securityError = errSecSuccess;
    
    CFStringRef password = CFSTR("Khalid");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12Data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}


-(void)attachSSL
{
    // Read .p12 file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CLIENT2" ofType:@"p12"];
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:path];
    
    // Import .p12 data
    CFArrayRef keyref = NULL;
    OSStatus sanityChesk = SecPKCS12Import((__bridge CFDataRef)pkcs12data,
                                           (__bridge CFDictionaryRef)[NSDictionary
                                                                      dictionaryWithObject:@"Khalid"
                                                                      forKey:(__bridge id)kSecImportExportPassphrase],
                                           &keyref);
    if (sanityChesk != noErr) {
        NSLog(@"Error while importing pkcs12 [%ld]", sanityChesk);
    } else
        NSLog(@"Success opening p12 certificate.");
    
    // Identity
    CFDictionaryRef identityDict = CFArrayGetValueAtIndex(keyref, 0);
    SecIdentityRef identityRef = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                      kSecImportItemIdentity);
    
    // Cert
    SecCertificateRef cert = NULL;
    OSStatus status = SecIdentityCopyCertificate(identityRef, &cert);
    if (status){
        NSLog(@"SecIdentityCopyCertificate failed.");
        return;
    }
    
    // the certificates array, containing the identity then the root certificate
    NSArray *myCerts = [[NSArray alloc] initWithObjects:(__bridge id)identityRef, (__bridge id)cert, nil];
    
    
    NSMutableDictionary * sslSettings = [[NSMutableDictionary alloc] init];
    
    [sslSettings setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
    [sslSettings setObject:(NSString *)kCFStreamSocketSecurityLevelTLSv1 forKey:(NSString*)kCFStreamSSLLevel];
    [sslSettings setObject:(NSString *)kCFStreamSocketSecurityLevelTLSv1 forKey:(NSString*)kCFStreamPropertySocketSecurityLevel];
    [sslSettings setObject:myCerts forKey:(NSString *)kCFStreamSSLCertificates];
    [sslSettings setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamSSLIsServer];

    
    [outputStream setProperty:sslSettings
                        forKey:(__bridge id)kCFStreamPropertySSLSettings];
    [inputStream setProperty:sslSettings
                       forKey:(__bridge id)kCFStreamPropertySSLSettings];
}

-(void)connectToIngenico
{
    /*NSString *thePath = [[NSBundle mainBundle] pathForResource:@"CLIENT2" ofType:@"p12"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
    
    SecIdentityRef identity;
    // extract the ideneity from the certificate
    [self extractIdentity :inPKCS12Data :&identity];
    
    certificate = NULL;
    SecIdentityCopyCertificate (identity, &certificate);
    // this disables certificate chain validation in ssl settings.*/
    
    ingenicoIP = @"192.168.100.118";
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSLog(@"Connecting to Ingenico %@:%@",ingenicoMAC,ingenicoIP);
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ingenicoIP, 12000, &readStream, &writeStream);

    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //[self attachSSL];
    
    
    [inputStream open];
    [outputStream open];
    
    
}


- (void) openDevice
{
    
    [self connectToIngenico];
    //[self broadCast];
}

- (void) enableDevice:(NSString*)data
{
    NSString *str = [@"23." stringByAppendingString:data];
    NSData *msg = [self buildMessage:str];
    [self sendMessage:msg];
}

- (void) paymentType:(NSString*)data
{
    NSString *str = [@"04.0B" stringByAppendingString:data];
    NSData *msg = [self buildMessage:str];
    [self sendMessage:msg];
}

- (void) transactionType:(NSString*)data
{
    NSString *str = [@"14." stringByAppendingString:data];
    NSData *msg = [self buildMessage:str];
    [self sendMessage:msg];
}

- (void) transactionAmount:(NSString*)data
{
    NSString *str = [@"13." stringByAppendingString:data];
    NSData *msg = [self buildMessage:str];
    [self sendMessage:msg];
}

- (void) authResponse:(NSString*)data
{
    NSString *str = [@"13." stringByAppendingString:data];
    NSData *msg = [self buildMessage:str];
    [self sendMessage:msg];
}

- (void) online:(BOOL)running
{
    if (running)
    {
        NSData *data = [self buildMessage:@"01.00000000"];
        [self sendMessage:data];
    }
    else
    {
        NSData *data = [self buildMessage:@"00.0000"];
        [self sendMessage:data];
    }
}

- (void) sendDIOMessage:(NSString*)data
{
    NSData *msg = [self buildMessage:data];
    [self sendMessage:msg];
}


- (void) cfgDevice:(NSNumber *)parm
{
    //int param = (int)parm;
    uint8_t ndx = 0;
    uint8_t buf[14];
    NSUInteger len = 11;
    int n = [parm intValue];
    switch (n)
    {
        case 81:
            buf[ndx++] = 0x02;
            buf[ndx++] = 0x36;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x2e;
            buf[ndx++] = 0x38;
            buf[ndx++] = 0x1d;
            buf[ndx++] = 0x31;
            buf[ndx++] = 0x1d;
            buf[ndx++] = 0x31;
            buf[ndx++] = 0x03;
            buf[ndx++] = 0x13;
            //NSUInteger len = ndx;
            break;
            
        case 141:
            buf[ndx++] = 0x02;
            buf[ndx++] = 0x36;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x2e;
            buf[ndx++] = 0x31;
            buf[ndx++] = 0x33;
            buf[ndx++] = 0x1d;
            buf[ndx++] = 0x31;
            buf[ndx++] = 0x34;
            buf[ndx++] = 0x1d;
            buf[ndx++] = 0x31;
            buf[ndx++] = 0x03;
            buf[ndx] = 0x1d;
            len = 14;
            break;
            
        default:
            break;
    }
    [outputStream write:buf maxLength:len];
}

- (void) sendEMVMessage:(NSNumber*)parm
{
    int n = [parm intValue];
    //uint8_t [] buf = {0x02};
    
    switch (n)
    {
        case 1:
            NSLog(@"1");
            break;
            
        default:
            break;
    }
}

- (void) readCardData:(NSNumber *)parm
{
    uint8_t ndx = 0;
    uint8_t buf[14];
    int n = [parm intValue];
    switch (n)
    {
        case 1:
            buf[ndx++] = 0x02;
            
            buf[ndx++] = 0x32;
            buf[ndx++] = 0x39;
            buf[ndx++] = 0x2e;
            
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            
            buf[ndx++] = 0x33;
            buf[ndx++] = 0x39;
            buf[ndx++] = 0x38;
            
            buf[ndx++] = 0x03;
            buf[ndx++] = 0x24;
            break;
            
        case 3:
            buf[ndx++] = 0x02;
            
            buf[ndx++] = 0x32;
            buf[ndx++] = 0x39;
            buf[ndx++] = 0x2e;
            
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            
            buf[ndx++] = 0x33;
            buf[ndx++] = 0x39;
            buf[ndx++] = 0x39;
            
            buf[ndx++] = 0x03;
            buf[ndx++] = 0x25;
            break;
            
        case 2:
            buf[ndx++] = 0x02;
            
            buf[ndx++] = 0x32;
            buf[ndx++] = 0x39;
            buf[ndx++] = 0x2e;
            
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            
            buf[ndx++] = 0x34;
            buf[ndx++] = 0x30;
            buf[ndx++] = 0x30;
            
            buf[ndx++] = 0x03;
            buf[ndx++] = 0x22;
            break;
            
        default:
            break;
    }
    NSUInteger len = 14;
    [outputStream write:buf maxLength:len];
}


- (NSData *)buildMessage:(NSString *)text
{
    NSString *str = [text stringByAppendingString:@"\x03"];
    NSString *hexstr = [UtilityRoutines stringToHex:str];
    
    char lrc = [UtilityRoutines calculateLRC:hexstr];
    
    NSMutableString *mstr = [NSMutableString string];
    [mstr appendString:@"02"];
    [mstr appendString:hexstr];
    [mstr appendFormat:@"%02x", lrc];
    NSString *xstr = [NSString stringWithString:mstr];
    
    NSData *data = [UtilityRoutines hexToBytes:xstr];
    return data;
}


- (void) sendAck
{
    NSLog(@"sendAck:");
    uint8_t buf[1];
    buf[0] = 0x06;
    NSUInteger count = 1;
    [outputStream write:buf maxLength:count];
}

- (void) messageReceived:(NSString *)message {
    
    NSLog(@"Message Received:");
}

- (void) sendMessage:(NSData*)data
{
    @try
    {
        [outputStream write:[data bytes] maxLength:[data length]];
    }
    @catch (NSException *exception) {
        NSLog(@"NSException at parse p2pe string: %@", exception);
    }
    
    NSLog(@"sendMessage: bytes written to port: %@", [data description]);
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %u", streamEvent);
    switch (streamEvent)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"NSStreamEventOpenCompleted: %@",theStream);
            if([theStream isKindOfClass:[NSOutputStream class]]){
                
            }
            break;
            
        case NSStreamEventHasBytesAvailable:
            NSLog(@"NSStreamEventHasBytesAvailable: %@",theStream);
            if (theStream == inputStream)
            {
                uint8_t buffer[1024] = {0};
                int len;
                while ([inputStream hasBytesAvailable])
                {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    NSLog(@"Errno %d",errno);
                    if (len > 0)
                    {
                        if (nil != buffer && 0x06 == buffer[0])
                        {
                            NSLog(@"Received ACK");
                        }
                        else
                        {
                            
                            NSData *input = [NSData dataWithBytes:buffer length:len];
                            [self processResponseBytes:input];
                        }
                    }
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            /*
            NSLog(@"NSStreamEventHasSpaceAvailable %@",theStream);
            if([theStream isKindOfClass:[NSOutputStream class]]){
                // #1
                // NO for client, YES for server.  In this example, we are a client
                // replace "localhost" with the name of the server to which you are connecting
                CFStringRef cfip = (__bridge CFStringRef)ingenicoIP;
                SecPolicyRef policy = SecPolicyCreateSSL(YES,cfip);
                SecTrustRef trust = (__bridge SecTrustRef)[theStream propertyForKey: (__bridge NSString *)kCFStreamPropertySSLPeerTrust];
                
                // #2
                CFArrayRef streamCertificates = (__bridge CFArrayRef)([theStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerCertificates]);
                // #3
                if(streamCertificates != nil){
                    SecTrustCreateWithCertificates(streamCertificates,
                                                   policy,
                                                   &trust);
                }
                // #4
                SecTrustSetAnchorCertificates(trust,(CFArrayRef) [NSArray arrayWithObject:(__bridge id)certificate]);
                
                // #5
                SecTrustResultType trustResultType = kSecTrustResultInvalid;
                OSStatus status = SecTrustEvaluate(trust, &trustResultType);
                if (status == errSecSuccess) {
                    // expect trustResultType == kSecTrustResultUnspecified
                    // until my cert exists in the keychain see technote for more detail.
                    if (trustResultType == kSecTrustResultUnspecified) {
                        NSLog(@"We can trust this certificate! TrustResultType: %d", trustResultType);
                    } else {
                        NSLog(@"Cannot trust certificate. TrustResultType: %d", trustResultType);
                    }
                } else {
                    NSLog(@"Creating trust failed: %d", status);
                }
                if (trust) {
                    CFRelease(trust);
                }
                if (policy) {
                    CFRelease(policy);
                }
            }
             */
            break;
        case NSStreamEventErrorOccurred:
        {
            NSError *theError = [theStream streamError];
            NSLog(@"Stream Error: %@",theError.description);
            [theStream close];
        }
            NSLog(@"NSStreamEventErrorOccurred: Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered:");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            //[theStream release];
            theStream = nil;
            break;
            
        default:
            NSLog(@"default: Unknown event");
            break;
    }
    
}

- (void) processResponseBytes:(NSData *)input
{
    NSUInteger ln = input.length;
    NSLog(@"InputStream data received: %lu",(unsigned long)ln);
    
    Byte *byteData = (Byte*)malloc(ln);
    memcpy(byteData, [input bytes], ln);
    unsigned char two = 0x02;
    if (byteData[0]== two)
    {
        unsigned char cm= byteData[1];
        NSLog(@"H %c", cm);
    }
    free(byteData);
    
    NSLog(@"Message Received: %@", input);
    NSLog(@"Message Bytes: %@", [input description]);
    
    NSString * output = [[NSString alloc] initWithData:input encoding:NSASCIIStringEncoding];
    NSLog(@"%@", output);
    //
    NSString *cmd = [output substringWithRange:NSMakeRange(1, 2)];
    int command = [ [cmd stringByReplacingOccurrencesOfString:@" " withString:@""] intValue ];
    NSString *subcmd = [output substringWithRange:NSMakeRange(4, 2)];
    int subcommand = 0;
    if (command == 33)
    {
        subcommand = [ [subcmd stringByReplacingOccurrencesOfString:@" " withString:@""] intValue ];
    }
    switch (command)
    {
        case 1:
            NSLog(@"Online response");
            //self.lblOutput.text = @"Terminal Online";
            break;
            
        case 9:
            NSLog(@"09. received.");
            //self.lblOutput.text = @"Card Inserted";
            break;
            
        case 4:
            NSLog(@"04. received.");
            //self.lblOutput.text = @"set payment type response received";
            break;
            
        case 7:
            NSLog(@"07. received.");
            //self.lblOutput.text = [@"Terminal stats: " stringByAppendingString:output];
            break;
            
        case 33:
            switch (subcommand)
        {
            case 2:
                NSLog(@"33 02 received.");
                //self.lblOutput.text = @"33 02 received.";
                break;
                
            case 3:
                NSLog(@"33 03 received.");
                //self.lblOutput.text = @"33 03 received.";
                break;
                
            case 5:
                NSLog(@"33 05 received.");
                //self.lblOutput.text = @"33 05 received.";
                
            default:
                break;
        }
            break;
            
        case 23:
            NSLog(@"Card swiped %@", [output substringWithRange:NSMakeRange(5, ln-6)]);
            [self parseCardData:[output substringWithRange:NSMakeRange(5, ln-7)]];
            break;
            
        case 50:
            NSLog(@"Card swiped %@", [output substringWithRange:NSMakeRange(5, ln-6)]);
            [self parseCardData:[output substringWithRange:NSMakeRange(2, ln-3)]];
            break;
            
        case 29:
            NSLog(@"Card data %@", [output substringWithRange:NSMakeRange(12, ln-13)]);
            break;
            
        default:
            NSLog(@"default- not handled.");
            break;
    }
}

- (void) parseCardData:(NSString *)parm
{
    char source = [parm characterAtIndex:0];
    NSLog(@"Source: %c", source);
    
    NSMutableDictionary *cardDat = [NSMutableDictionary dictionaryWithCapacity:10];
    if (source == 0x63 || source == 0x43)
    {
        [cardDat setObject:@"Contacless" forKey:@"Source"];
    }
    else if (source == 0x4d || source == 0x4d)
    {
        [cardDat setObject:@"Magstripe" forKey:@"Source"];
    }
    else if (source == 0x35)
    {
        [cardDat setObject:@"ApplePay" forKey:@"Source"];
    }
    
    if (source != 0x35)
    {
        NSRange fs1 = [parm rangeOfString:@"\x1c"];
        NSString *track1 = [parm substringToIndex:fs1.location];
        NSString *track = [parm substringFromIndex:fs1.location+1];
        if(parm.length > 12 && parm.length < 30)
        {
            NSString *tmp1 = [parm substringFromIndex:fs1.location + 1];
            NSRange fs = [tmp1 rangeOfString:@"\x1c"];
            NSString *data = [tmp1 substringToIndex:fs.location];
            [cardDat setObject:data forKey:@"Data"];
        }
        else if(track.length > 50)
        {
            NSRange fs2 = [track rangeOfString:@"\x1c"];
            NSString *track2 = [track substringToIndex:fs2.location];
            NSString *p2pestr = [track substringFromIndex:fs2.location+1];
            
            NSDictionary *track1Data = [self parseTrack1:track1];
            NSDictionary *track2Data = [self parsetrack2:track2];
            NSDictionary *p2peData = [self parseP2PEdata:p2pestr];
            [cardDat addEntriesFromDictionary:track1Data];
            [cardDat addEntriesFromDictionary:track2Data];
            [cardDat addEntriesFromDictionary:p2peData];
        }
        else
        {
            NSDictionary *track1Data = [self parseTrack1:track1];
            NSDictionary *track2Data = [self parsetrack2:track];
            [cardDat addEntriesFromDictionary:track1Data];
            [cardDat addEntriesFromDictionary:track2Data];
        }
        
    }
    else
    {
        NSDictionary *applepayData = [self parseApplePay:parm];
        [cardDat addEntriesFromDictionary:applepayData];
    }
    _cardData = [cardDat copy];
    
}


@end
