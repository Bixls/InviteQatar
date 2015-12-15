//
//  SearchPageViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 19,8//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderContainerViewController.h"
#import "FooterContainerViewController.h"

@interface SearchPageViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,headerContainerDelegate,FooterContainerDelegate>


@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;


@property (nonatomic,strong) NSMutableArray *filteredNames;





@end
