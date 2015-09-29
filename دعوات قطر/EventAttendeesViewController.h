//
//  EventAttendeesViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderContainerViewController.h"

@interface EventAttendeesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,headerContainerDelegate>

@property (nonatomic)NSInteger eventID;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)btnSeeMorePressed:(id)sender;

@end
