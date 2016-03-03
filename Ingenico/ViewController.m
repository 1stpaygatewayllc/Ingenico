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
