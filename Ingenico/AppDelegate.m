//
//  AppDelegate.m
//  Ingenico
//
//  Created by Gal Blank on 3/3/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

static AppDelegate *sharedAppDelegateInstance = nil;

@synthesize selfIP;

+ (AppDelegate *)sharedInstance {
    @synchronized(self) {
        if (sharedAppDelegateInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedAppDelegateInstance;
}



+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedAppDelegateInstance == nil) {
            sharedAppDelegateInstance = [super allocWithZone:zone];
            // assignment and return on first allocation
            return sharedAppDelegateInstance;
        }
    }
    // on subsequent allocation attempts return nil
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)init {
    if (self = [super init]) {
       
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.selfIP = [self getIPAddress];
    
    ViewController *mainVc = [[ViewController alloc] init];
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:mainVc];
    rootVC.navigationBarHidden = YES;
    self.window.rootViewController = rootVC;

    [self.window makeKeyAndVisible];

    return YES;
}


-(NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Get NSString from C String
                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
