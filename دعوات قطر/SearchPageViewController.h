//
//  SearchPageViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 19,8//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPageViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;

@property (nonatomic,strong) NSMutableArray *filteredNames;


- (IBAction)btnBackPressed:(id)sender;
- (IBAction)btnHomePressed:(id)sender;


@end
