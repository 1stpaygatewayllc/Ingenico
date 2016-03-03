//
//  IPAddress.h
//  TestApp
//
//  Created by Khalid Khan on 6/17/15.
//  Copyright (c) 2015 KhalidKhan. All rights reserved.
//

#ifndef TestApp_IPAddress_h
#define TestApp_IPAddress_h


/*
 *  IPAddress.h
 *  PersonalProxy
 *
 *  Created by Chris Whiteford on 2009-02-20.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#define MAXADDRS	32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
void GetHWAddresses();

#endif
