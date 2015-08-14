//
//  CommentsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) UIImage *postImage;
@property (nonatomic,strong) NSString *postDescription;
@property (nonatomic) NSInteger postID;
@property (nonatomic) NSInteger postType;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;



- (IBAction)btnSendCommentPressed:(id)sender;




@end
