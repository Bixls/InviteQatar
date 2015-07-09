//
//  MessagesViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
 
@property (weak, nonatomic) IBOutlet UITableView *tableView;



- (IBAction)btnSeeMorePressed:(id)sender;

@end
