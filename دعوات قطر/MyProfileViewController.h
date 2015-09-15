//
//  MyProfileViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 3,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLatestEventsTableViewCell.h"
#import "NetworkConnection.h"

@interface MyProfileViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIDocumentInteractionControllerDelegate,NetworkConnectionDelegate>

@property (strong, nonatomic) IBOutlet UIView *smallerView;
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
@property (weak, nonatomic) IBOutlet UIButton *btnSeeMore;
@property (weak, nonatomic) IBOutlet UIImageView *imgSeeMore;
@property (weak, nonatomic) IBOutlet UILabel *activateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activateLabel2;
- (IBAction)btnSharePressed:(id)sender;

@end
