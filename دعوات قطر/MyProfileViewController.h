//
//  MyProfileViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 3,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLatestEventsTableViewCell.h"

@interface MyProfileViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *myProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *myName;
@property (weak, nonatomic) IBOutlet UILabel *myGroup;
@property (weak, nonatomic) IBOutlet UIButton *btnActivateAccount;
@property (weak, nonatomic) IBOutlet UIImageView *imgActivateAccount;

@property (weak, nonatomic) IBOutlet UIButton *btnEditAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnNewEvent;

@property (weak, nonatomic) IBOutlet UIButton *btnAllEvents;
@property (weak, nonatomic) IBOutlet UIButton *btnInvitationNum;
@property (weak, nonatomic) IBOutlet UIButton *btnVIPNum;

@end
