//
//  MessageHandler.h
//  TestApp
//
//  Created by Khalid Khan on 3/18/15.
//  Copyright (c) 2015 KhalidKhan. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface MessageHandler : NSObject <NSStreamDelegate>
{
    int listenToPort;
    int listeningSocket;
    NSString * ingenicoIP;
    NSString * ingenicoMAC;
    SecCertificateRef certificate;
}
@property (nonatomic, retain) NSInputStream         *inputStream;
@property (nonatomic, retain) NSOutputStream        *outputStream;

@property (strong, nonatomic) NSDictionary *cardData;

- (NSData *)buildMessage:(NSString *)text;

//- (void) initNetworkCommunication;
- (void) messageReceived:(NSString *)message;
- (void) sendAck;
- (void) sendMessage:(NSData*)data;
- (void) sendDIOMessage:(NSString*)data;
- (void) processResponseBytes:(NSData *)input;

- (void) cfgDevice:(NSNumber*)parm;
- (void) enableDevice:(NSString*)data;
- (void) openDevice;
- (void) paymentType:(NSString*)data;
- (void) transactionType:(NSString*)data;
- (void) transactionAmount:(NSString*)data;
- (void) authResponse:(NSString*)data;
- (void) online:(BOOL)running;
- (void) readCardData:(NSNumber*)parm;
- (void) parseCardData:(NSString*)parm;
- (void) sendEMVMessage:(NSNumber*)parm;
-(void)sendDiscoveryBroadcast;
@end