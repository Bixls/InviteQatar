//
//  ChooseTypeViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 10,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol chooseTypeViewControllerDelegate <NSObject>

-(void)selectedCategory:(NSDictionary *)category;

@end

@interface ChooseTypeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) id <chooseTypeViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)btnClosePressed:(id)sender;


@end
