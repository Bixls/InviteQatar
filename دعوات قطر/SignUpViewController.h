//
//  SignUpViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chooseGroupViewController.h"
#import "OfflinePicturesViewController.h"

@interface SignUpViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,chooseGroupViewControllerDelegate,UIActionSheetDelegate , UIAlertViewDelegate,offlinePicturesViewControllerDelegate>



- (IBAction)btnSignUpPressed:(id)sender;
- (IBAction)btnBackgroundPressed:(id)sender;

@end
