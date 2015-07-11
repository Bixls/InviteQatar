//
//  EditAccountViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OfflinePicturesViewController.h"
@interface EditAccountViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,offlinePicturesViewControllerDelegate,UIActionSheetDelegate>

@property (nonatomic,strong)NSString *userName;
@property (nonatomic,strong)UIImage *userPic;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
