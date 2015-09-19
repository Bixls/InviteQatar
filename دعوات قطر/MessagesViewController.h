//
//  MessagesViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseDateViewController.h"

@interface MessagesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate ,chooseDateViewControllerDelegate >
 
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *innerView;

- (IBAction)newMsgBtnPressed:(id)sender;

@end
