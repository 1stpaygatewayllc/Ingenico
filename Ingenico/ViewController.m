//
//  ViewController.m
//  Ingenico
//
//  Created by Gal Blank on 3/3/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

#import "ViewController.h"
#import <mobilesdkfw/mobilesdkfw.h>
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController


@synthesize cardData;
@synthesize lblOutput;
@synthesize tfOpen;
@synthesize tfInput;
@synthesize tfOnline;
@synthesize tfTransType;
@synthesize tfPaymentType;
@synthesize tfSetAmount;
@synthesize tfAuthResp;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [IngenicoDriver sharedIngenicoInstance];

    devicesTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    devicesTable.delegate = self;
    devicesTable.dataSource = self;
    [self.view addSubview:devicesTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consumeMessage:) name:@"internal.discovereddevices" object:nil];
    Message * msg = [[Message alloc] initWithRoutKey:@"internal.discovernetowrkswipers"];
    msg.params = @{@"device":@"ipp320",@"selfip":[AppDelegate sharedInstance].selfIP};
    [[MessageDispatcher sharedDispacherInstance] addMessageToBus:msg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)consumeMessage:(NSNotification*)notif
{
    Message * msg = [notif.userInfo objectForKey:@"message"];
    if([msg.routingKey caseInsensitiveCompare:@"internal.discovereddevices"] == NSOrderedSame){
        devicesArray = [msg.params objectForKey:@"devices"];
        if(devicesArray && devicesArray.count > 0){
            [devicesTable reloadData];
        }
    }
}


/*
- (IBAction)touchOPENbtn:(UIButton *)sender
{
    NSLog(@"Touched Open Button");
    if (m_MessageHandler == nil)
    {
        m_MessageHandler = [[MessageHandler alloc] init];
        NSLog(@"Created an instance of MessageHandler");
    }
    [m_MessageHandler openDevice];
}

- (IBAction)touchDisplayDatabtn:(UIButton *)sender
{
    NSDictionary *data = m_MessageHandler.cardData;
    NSMutableString *results = [NSMutableString stringWithCapacity:200];
    for (id key in data)
    {
        NSLog(@"%@    := %@", key, data[key]);
        [results appendFormat:@"%@  = %@ \n", key, data[key]];
    }
    lblOutput.text = [results copy];
}

// to do: CFG buttons handling is qnd
- (IBAction)touchCFGbtn:(UIButton *)sender
{
    NSLog(@"Configure Cless");
    NSNumber *i = [NSNumber numberWithInt:81];
    [m_MessageHandler cfgDevice:i];
}

- (IBAction)touchCFG2btn:(UIButton *)sender
{
    NSLog(@"Configure Cless");
    NSLog(@"Configure Cless");
    NSNumber *i = [NSNumber numberWithInt:141];
    [m_MessageHandler cfgDevice:i];
}

- (IBAction)touchCFG3btn:(UIButton *)sender
{
    NSString *address = @"error";
    NSString *netmask = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        temp_addr = interfaces;
        int ctr = 0;
        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                    netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
            ctr++;
        }
        
        NSLog(@"Counter %u", ctr);
    }
    
    // Strings to in_addr:
    struct in_addr localAddr;
    struct in_addr netmaskAddr;
    inet_aton([address UTF8String], &localAddr);
    inet_aton([netmask UTF8String], &netmaskAddr);
    
    NSString *localAddress = [NSString stringWithUTF8String:inet_ntoa(localAddr)];
    NSLog(localAddress);
    
    // The broadcast address calculation:
    localAddr.s_addr |= ~(netmaskAddr.s_addr);
    // in_addr to string:
    NSString *broadCastAddress = [NSString stringWithUTF8String:inet_ntoa(localAddr)];
    NSLog(broadCastAddress);
    
    
    NSString *netmaskAddress = [NSString stringWithUTF8String:inet_ntoa(netmaskAddr)];
    NSLog(netmaskAddress);
    
    
    //NSString *broadcastAddr = @"192.168.1.255";
    //NSString *subnet = @"255.255.255.0";
    uint32_t ipbc;
    uint32_t ipmask;
    
    struct in_addr addr;
    if (inet_aton([broadCastAddress UTF8String], &addr) != 0) {
        ipbc = ntohl(addr.s_addr);
        NSLog(@"Broadcast addr: %08x", ipbc);
    } else {
        NSLog(@"invalid address");
    }
    
    if (inet_aton([netmaskAddress UTF8String], &addr) != 0) {
        ipmask = ntohl(addr.s_addr);
        NSLog(@"%08x", ipmask);
    } else {
        NSLog(@"invalid address");
    }
    
    uint32_t ipnetid = (ipbc & ipmask);
    NSLog(@"Network Id: %08x", ipnetid);
    
    int len = ipbc - ipnetid;
    int ctr = 0;
    while (len > ctr++)
    {
        unsigned int ip = ipnetid++; //however you get the IP as unsigned int
        unsigned int part1, part2, part3, part4;
        
        part1 = ip/16777216;
        ip = ip%16777216;
        part2 = ip/65536;
        ip = ip%65536;
        part3 = ip/256;
        ip = ip%256;
        part4 = ip;
        
        NSString *fullIP = [NSString stringWithFormat:@"%d.%d.%d.%d", part1, part2, part3, part4];
        NSLog(fullIP);
        //NSLog(@"Counter: %u", ipnetid++);
    }
    
    
    freeifaddrs(interfaces);
    
}

- (IBAction)touchCFG4btn:(UIButton *)sender
{
    
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    int i;
    NSString *deviceIP = nil;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;        // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;
        
        NSLog(@"Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
        
        //decided what adapter you want details for
        if (strncmp(if_names[i], "en", 2) == 0)
        {
            NSLog(@"Adapter en has a IP of %s", ip_names[i]);
        }
        NSLog(@"Adapter en has a IP of %s", ip_names[i]);
    }
}

- (IBAction)discoverIngenico:(UIButton *)sender
{
    [m_MessageHandler sendDiscoveryBroadcast];
}

- (IBAction)touchENABLEbtn:(UIButton *)sender
{
    [m_MessageHandler enableDevice:self.tfEnable.text];
}

- (IBAction)touchSTARTEMVbtn:(UIButton *)sender
{
    [m_MessageHandler sendEMVMessage: [NSNumber numberWithInt:1]];
}

- (IBAction)touchTRANSTYPEbtn:(UIButton *)sender
{
    [m_MessageHandler sendEMVMessage: [NSNumber numberWithInt:2]];
}

- (IBAction)touchPYMTTYPEbtn:(UIButton *)sender
{
    [m_MessageHandler sendEMVMessage: [NSNumber numberWithInt:3]];
}

- (IBAction)touchAMOUNTbtn:(UIButton *)sender
{
    [m_MessageHandler sendEMVMessage: [NSNumber numberWithInt:4]];
}

- (IBAction)touchAUTHRESP:(UIButton *)sender
{
    [m_MessageHandler sendEMVMessage: [NSNumber numberWithInt:5]];
}

- (IBAction)touchONLINEbtn:(UIButton *)sender
{
    NSString *btntitle = sender.titleLabel.text;
    NSLog(@"Touched Online Button");
    NSString *nstOnline = @"ONLINE";
    NSString *nstOffline = @"OFFLINE";
    
    if ([nstOnline isEqualToString:btntitle])
    {
        [m_MessageHandler online:true];
        [sender setTitle:nstOffline forState:(UIControlStateNormal)];
    }
    else if ([nstOffline isEqualToString:btntitle])
    {
        [m_MessageHandler online:false];
        [sender setTitle:nstOnline forState:(UIControlStateNormal)];
    }
}

- (IBAction)touchOFFLINEbtn:(UIButton *)sender
{
    [m_MessageHandler online:false];
}

- (IBAction)touchSENDMSGbtn:(UIButton *)sender
{
    NSString *txt = self.tfInput.text;
    [m_MessageHandler sendDIOMessage:txt];
    NSLog(@"Sent %@", txt);
}
*/
#pragma mark -
#pragma mark UITableViewDelegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return devicesArray.count;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return(indexPath);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kSSAutoCompleteCell = @"kMainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSAutoCompleteCell];
    
    if(cell == nil)
    {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kSSAutoCompleteCell];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor blackColor]]; //[UIColor colorWithRed:54.0 / 255.0 green:154.0 / 255.0 blue:238.0 / 255.0 alpha:0.9]];
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0]];
        cell.accessoryType             = UITableViewCellAccessoryNone;
        cell.textLabel.numberOfLines   = 0;
        cell.selectionStyle            = UITableViewCellSelectionStyleGray;
        cell.backgroundColor           = [UIColor whiteColor];
        
        [cell.detailTextLabel setTextColor:[UIColor blackColor]]; //[UIColor colorWithRed:54.0 / 255.0 green:154.0 / 255.0 blue:238.0 / 255.0 alpha:0.9]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
    }
    
    NSMutableDictionary * item = [devicesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"ip"];
    cell.detailTextLabel.text = [item objectForKeyedSubscript:@"mac"];
    
    return(cell);
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}
@end
