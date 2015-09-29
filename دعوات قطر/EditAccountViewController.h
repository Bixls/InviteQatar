//
//  EditAccountViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OfflinePicturesViewController.h"
#import "chooseGroupViewController.h"
#import "customAlertView.h"
#import "HeaderContainerViewController.h"

@interface EditAccountViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,offlinePicturesViewControllerDelegate,UIActionSheetDelegate,chooseGroupViewControllerDelegate,customAlertViewDelegate,headerContainerDelegate>

@property (nonatomic,strong)NSString *userName;
@property (nonatomic,strong)NSString *groupName;
@property (nonatomic)NSInteger groupID;
@property (nonatomic,strong)UIImage *userPic;

@property (weak, nonatomic) IBOutlet customAlertView *customAlert;
@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *btnSave;

- (IBAction)btnSelectedGroupPressed:(id)sender;


@end
