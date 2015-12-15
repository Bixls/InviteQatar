//
//  CreateEventViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 1,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseTypeViewController.h"
#import "ChooseDateViewController.h"
#import "NetworkConnection.h"
#import "customAlertView.h"
#import "HeaderContainerViewController.h"
#import "FooterContainerViewController.h"

@interface CreateEventViewController : UIViewController <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate,chooseTypeViewControllerDelegate,chooseDateViewControllerDelegate,UIAlertViewDelegate,customAlertViewDelegate,headerContainerDelegate,FooterContainerDelegate>

@property (nonatomic) NSInteger createOrEdit;
@property (nonatomic) NSInteger eventID;
@property (nonatomic,strong) NSDictionary *event;
@property (nonatomic) NSInteger editMode;
@property (weak, nonatomic) IBOutlet UIView *innerView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePicker;

@property (weak, nonatomic) IBOutlet UIButton *btnChoosePic;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIButton *btnMarkComments;

@property (weak, nonatomic) IBOutlet UIButton *btnMarkVIP;
@property (weak, nonatomic) IBOutlet UIButton *btnMarkNormal;

@property (weak, nonatomic) IBOutlet UIButton *btnChooseType;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseDate;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblAdmin;
@property (weak, nonatomic) IBOutlet UILabel *normalRadioButton;
@property (weak, nonatomic) IBOutlet UILabel *VIPRadioButton;
@property (weak, nonatomic) IBOutlet UILabel *inviteesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgChoosePic;
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;

//@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)btnChooseInviteesPressed:(id)sender;

- (IBAction)btnChoosePicPressed:(id)sender;

- (IBAction)btnChooseInvitation:(id)sender;

- (IBAction)btnSubmitPressed:(id)sender;


- (IBAction)btnMarkCommentsPressed:(id)sender;
- (IBAction)RadioButtonPressed:(UIButton *)sender;



- (IBAction)datePickerAction:(id)sender;


@end
