//
//  InviteViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic)NSInteger createMsgFlag;
@property(nonatomic) NSInteger creatorID;
@property(nonatomic) NSInteger eventID;
@property(nonatomic) NSInteger normORVIP;
@property(nonatomic,strong) NSDictionary *group;
@property(nonatomic,strong)NSArray *invitees;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnMarkAll;
@property (weak, nonatomic) IBOutlet UILabel *inviteesNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *VIPNumberLabel;
@property (weak,nonatomic) IBOutlet UILabel *VIPlbl;



- (IBAction)btnInvitePressed:(id)sender;
@end
