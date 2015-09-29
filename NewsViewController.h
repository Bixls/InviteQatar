//
//  NewsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 8,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderContainerViewController.h"
@interface NewsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,headerContainerDelegate>

@property(nonatomic,strong) NSDictionary *news;

@property (weak, nonatomic) IBOutlet UILabel *newsSubject;
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UILabel *newsDate;
@property (weak, nonatomic) IBOutlet UILabel *newsTime;

@property (weak, nonatomic) IBOutlet UITextView *newsDescription;

@property (weak, nonatomic) IBOutlet UIButton *btnComments;
@property (weak, nonatomic) IBOutlet UIImageView *imgComments;
@property (weak, nonatomic) IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet UITextField *commentsTextField;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsHeightLayoutConstraint;

@end
