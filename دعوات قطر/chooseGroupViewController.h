//
//  chooseGroupViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol chooseGroupViewControllerDelegate <NSObject>

-(void)selectedGroup:(NSDictionary *)group ;

@end


@interface chooseGroupViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic)NSInteger eventID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,weak) id <chooseGroupViewControllerDelegate> delegate;
- (IBAction)btnDismissPressed:(id)sender;
@property (nonatomic) NSInteger flag;

@end
