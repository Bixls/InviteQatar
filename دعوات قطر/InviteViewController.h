//
//  InviteViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderContainerViewController.h"

@interface InviteViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,headerContainerDelegate>


@property(nonatomic)NSInteger createMsgFlag;
@property(nonatomic) NSInteger creatorID;
@property(nonatomic) NSInteger eventID;
@property(nonatomic) NSInteger normORVIP;
@property(nonatomic,strong) NSDictionary *group;
@property(nonatomic,strong)NSArray *invitees;
@property(nonatomic)BOOL inviteOthers;
@property(nonatomic)BOOL editingMode;
@property(nonatomic,strong)NSArray *previousInvitees;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnMarkAll;
@property (weak, nonatomic) IBOutlet UILabel *inviteesNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *VIPNumberLabel;
@property (weak,nonatomic) IBOutlet UILabel *VIPlbl;



- (IBAction)btnInvitePressed:(id)sender;
@end
