//
//  ViewController.h
//  Ingenico
//
//  Created by Gal Blank on 3/3/16.
//  Copyright © 2016 Goemerchant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    UITableView * devicesTable;
    NSMutableArray * devicesArray;
}

@property (strong, nonatomic) NSString              *cardData;

@property (weak, nonatomic) IBOutlet UILabel        *lblOutput;
@property (weak, nonatomic) IBOutlet UITextField    *tfOpen;
@property (weak, nonatomic) IBOutlet UITextField    *tfInput;
@property (weak, nonatomic) IBOutlet UITextField    *tfOnline;
@property (weak, nonatomic) IBOutlet UITextField    *tfTransType;
@property (weak, nonatomic) IBOutlet UITextField    *tfPaymentType;
@property (weak, nonatomic) IBOutlet UITextField    *tfSetAmount;
@property (weak, nonatomic) IBOutlet UITextField    *tfAuthResp;
@property (weak, nonatomic) IBOutlet UITextField    *tfEnable;


@end

