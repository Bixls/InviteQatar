//
//  CreateEventViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 1,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "CreateEventViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "EventViewController.h"
#import "chooseGroupViewController.h"

static void *adminMsgContext = &adminMsgContext;

@interface CreateEventViewController ()

@property (nonatomic,strong)NSArray *invitationTypes;
@property (nonatomic)NSString *selectedType;
@property (nonatomic) int commentsFlag;
@property (nonatomic) int vipFlag;
@property (nonatomic) BOOL allowEditing;
@property (strong,nonatomic) ASIFormDataRequest *imageRequest;
@property (nonatomic) NSInteger imageURL;
@property (strong , nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic) int flag;
@property (nonatomic) int uploaded;
@property (nonatomic) NSInteger btnPressed;
@property (nonatomic) NSInteger continueFlag;
@property(nonatomic,strong)NSDictionary *selectedCategory;
@property(nonatomic,strong)NSDictionary *createdEvent;
@property (nonatomic,strong) NSString *selectedDate;
@property (nonatomic) BOOL stopGettingAttendees;
@property (nonatomic,strong) UIImage *selectedImage;
@property (nonatomic,strong) NSString *normalUnchecked;
@property (nonatomic,strong) NSString *normalChecked;
@property (nonatomic,strong) NSString *unChecked;
@property (nonatomic,strong) NSString *checked;
@property (nonatomic,strong) NSMutableArray *invitees;
@property (nonatomic,strong) NSArray *selectedUsers;
@property (nonatomic,strong) NSArray *previousInvitees;
@property (nonatomic) NSInteger VIPPoints;
@property (nonatomic) BOOL allowCreation;
@property (nonatomic,strong) NetworkConnection *adminMgsConnection;
@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet customAlertView *customAlert;
@property (nonatomic) BOOL isEventCreated;
@property (nonatomic) BOOL isUsersInvited;
@property (strong, nonatomic) UIActivityIndicatorView *gettingInvitees;
@property (strong, nonatomic) UIActivityIndicatorView *uploadingPicture;
@property (strong, nonatomic) UIActivityIndicatorView *creatingEvent;
@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.hidden = YES;
    [self.textView setReturnKeyType:UIReturnKeyDone];
    self.textView.delegate = self;
    self.textField.delegate = self;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID  = [self.userDefaults integerForKey:@"userID"];
    self.VIPPoints = [self.userDefaults integerForKey:@"VIPPoints"];
    self.invitees = [[NSMutableArray alloc]init];
    self.commentsFlag = 0;
    self.vipFlag = -1;
    self.allowCreation = true;
    self.unChecked =@"⚪️";
    self.checked = @"🔘";
    
    self.VIPRadioButton.text = self.unChecked;
    self.normalRadioButton.text = self.checked;
    self.vipFlag = 0;
    
    self.inviteesLabel.text = [self arabicNumberFromEnglish:0];
    self.inviteesLabel.textColor = [UIColor redColor];
    [self.btnMarkComments setTitle:@"\u274F  السماح بالتعليقات" forState:UIControlStateNormal];
    
    //self.imageURL = @"default";
    if (self.event != nil && self.createOrEdit ==1) {
        self.vipFlag = [self.event[@"VIP"]integerValue];
//        NSLog(@"%d",self.vipFlag);
        self.selectedType = self.event[@"eventType"];
        self.textField.text = self.event[@"subject"];
        self.textView.text = self.event[@"description"];
        self.selectedDate = self.event[@"TimeEnded"];
        self.commentsFlag = [self.event[@"comments"]integerValue];
        self.imageURL = [self.event[@"picture"]integerValue];
        if (self.commentsFlag == 0) {
             [self.btnMarkComments setTitle:@"\u274F  السماح بالتعليقات" forState:UIControlStateNormal];
        }else{
            [self.btnMarkComments setTitle:@"\u2713 السماح بالتعليقات" forState:UIControlStateNormal];
        }
        if (self.vipFlag == 0) {
            self.VIPRadioButton.text = self.unChecked;
            self.normalRadioButton.text = self.checked;
//            [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
        }else if(self.vipFlag == 1){
//             [self.btnMarkVIP setTitle:@"\u2713 VIP" forState:UIControlStateNormal];
            self.VIPRadioButton.text = self.checked;
            self.normalRadioButton.text = self.unChecked;
        }
    }
    
    [self.customAlertView setHidden:YES];
    self.customAlert.delegate = self;
    
//    [self.navigationItem setHidesBackButton:YES];
    self.adminMgsConnection = [[NetworkConnection alloc]init];
    
}
-(void)refreshInvitees{
    if (self.eventID && self.createOrEdit == 1) {
        NSInteger temp = self.invitees.count + self.previousInvitees.count;
        self.inviteesLabel.text = [self arabicNumberFromEnglish:temp];
    }else{
        self.inviteesLabel.text = [self arabicNumberFromEnglish:self.invitees.count];
    }
    
    if (self.invitees.count <= 0) {
        self.inviteesLabel.textColor = [UIColor redColor];
    }else{
        self.inviteesLabel.textColor = [UIColor orangeColor];
    }

}

-(void)updateVIPPoints{
    if (self.vipFlag == 1 && self.invitees.count > 0) {
        self.VIPPoints = [self.userDefaults integerForKey:@"VIPPoints"];
//        [self updateStoredVIPPointsNumber];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    

    if (self.eventID && self.createOrEdit ==1 && self.stopGettingAttendees == NO) {
        [self getAttendees];
        self.stopGettingAttendees = YES;
    }
    [self.adminMgsConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:adminMsgContext];
    [self.adminMgsConnection getCreateEventAdminMsg];
    
    if ([self.userDefaults objectForKey:@"invitees"] != nil) {
        NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:[self.userDefaults objectForKey:@"invitees"]];
        NSArray *tempArray = tempDict[@"data"];
        if ([tempArray isEqualToArray:self.selectedUsers]) {
            //do nothing
        }else{
            self.selectedUsers = tempArray;
            [self.invitees removeAllObjects];
            for (int i =0; i < tempArray.count; i++) {
                NSDictionary *dict = tempArray[i];
                NSInteger userID = [dict[@"id"]integerValue];
                NSDictionary *temp = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)userID],@"id", nil];
                [self.invitees addObject:temp];
            }
            [self refreshInvitees];
            [self updateVIPPoints];
            
        }
    }
    [self getCreateEventAdminMsg];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.adminMgsConnection removeObserver:self forKeyPath:@"response" context:adminMsgContext];
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == adminMsgContext) {
        if ([keyPath isEqualToString:@"response"]) {
            
        }
    }
}

-(void)getCreateEventAdminMsg {
    NSDictionary *getAdminMsg = @{@"FunctionName":@"getString" , @"inputs":@[@{@"name":@"createEvent",
                                                                             }]};
    NSMutableDictionary *getAdminMsgTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getAdminMsg",@"key", nil];
    
    [self postRequest:getAdminMsg  withTag:getAdminMsgTag];
}

-(NSString *)arabicNumberFromEnglish:(NSInteger)num {
    NSNumber *someNumber = [NSNumber numberWithInteger:num];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ar"];
    [formatter setLocale:gbLocale];
    return [formatter stringFromNumber:someNumber];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"invitationTypes"]) {
        ChooseTypeViewController *chooseTypeController = segue.destinationViewController;
        chooseTypeController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"chooseDate"]){
        ChooseDateViewController *chooseDateController = segue.destinationViewController;
        chooseDateController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"invite"]){
        chooseGroupViewController *chooseGroupController = segue.destinationViewController;
        chooseGroupController.eventID = self.eventID;
        chooseGroupController.VIPFlag = self.vipFlag;
        chooseGroupController.flag = 1;
        if (self.eventID) {
            //chooseGroupController.inviteOthers = YES;
            chooseGroupController.editingMode = YES;
        }
        if (self.invitees.count > 0 && self.createOrEdit == 0) {
            chooseGroupController.invitees = self.selectedUsers;
        }else if (self.selectedUsers.count > 0 && self.createOrEdit == 1){
            chooseGroupController.invitees = self.selectedUsers;
            chooseGroupController.previousInvitees = self.previousInvitees;
        }
    }
}

#pragma mark - ChooseType ViewController Delegate
-(void)selectedCategory:(NSDictionary *)category{
    self.selectedCategory = category;
    self.selectedType = self.selectedCategory[@"catID"];
    [self.btnChooseType setTitle:category[@"catName"] forState:UIControlStateNormal];
}

#pragma mark - ChooseDate ViewController Delegate 
-(void)selectedDate:(NSString *)date{
    self.selectedDate = date;
    [self.btnChooseDate.titleLabel setFont:[UIFont systemFontOfSize:13]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
    [formatter setLocale:qatarLocale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateString = [formatter dateFromString:self.selectedDate];
    NSString *arabicDate = [formatter stringFromDate:dateString];
    NSString *dateWithoutSeconds = [arabicDate substringToIndex:16];
    
    [self.btnChooseDate setTitle:[dateWithoutSeconds stringByReplacingOccurrencesOfString:@"-" withString:@"/"] forState:UIControlStateNormal];
}


#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.textField resignFirstResponder];
    return YES;
}

#define MAXLENGTH 30
- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAXLENGTH || returnKey;
}

#pragma mark - TextView Delegate Methods

//-(void)textViewDidBeginEditing:(UITextView *)textView {
//    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"تم" style:UIBarButtonItemStyleDone target:self action:@selector(removeKeyboard)];
//
//    [self.navigationItem setRightBarButtonItem:doneBtn];
//}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
//        NSLog(@"Return pressed");
        [textView resignFirstResponder];
    } else {
//        NSLog(@"Other pressed");
    }
    return YES;
}


-(void)removeKeyboard{
    [self.textView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
//    NSLog(@"%@",self.textView.text);
}



#pragma mark - Image Picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        self.selectedImage = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        self.selectedImage = [self resizeImageWithImage:image];
        [self.btnChoosePic setImage:nil forState:UIControlStateNormal];
        self.imgChoosePic.image = self.selectedImage;
        self.flag = 1;
        
        
    }
   
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Connection setup

-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict{
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    NSString *urlString = @"http://bixls.com/Qatar/" ;
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.username =@"admin";
    request.password = @"admin";
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Authorization" value:authValue];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    request.allowCompressedResponse = NO;
    request.useCookiePersistence = NO;
    request.shouldCompressRequestBody = NO;
    request.userInfo = dict;
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    
    [request startAsynchronous];
    
    
    
}

-(void)postPictureWithTag:(NSMutableDictionary *)dict{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    
    
    self.imageRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://bixls.com/Qatar/upload.php"]];
    [self.imageRequest setUseKeychainPersistence:YES];
    self.imageRequest.delegate = self;
    self.imageRequest.username = @"admin";
    self.imageRequest.password = @"admin";
    [self.imageRequest setRequestMethod:@"POST"];
    [self.imageRequest addRequestHeader:@"Authorization" value:authValue];
//    [self.imageRequest addRequestHeader:@"Accept" value:@"application/json"];
//    [self.imageRequest addRequestHeader:@"content-type" value:@"application/json"];
    self.imageRequest.allowCompressedResponse = NO;
    
    
    self.imageRequest.useCookiePersistence = NO;
    self.imageRequest.shouldCompressRequestBody = NO;
    self.imageRequest.userInfo = dict;
//    [self.imageRequest setPostValue:@"6" forKey:@"id"];
    [self.imageRequest setPostValue:@"user" forKey:@"type"];
    [self.imageRequest addData:[NSData dataWithData:UIImageJPEGRepresentation(self.selectedImage, 0.9)] withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"fileToUpload"];
    

    
    [self.imageRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    //NSString *responseString = [request responseString];
   
    NSData *responseData = [request responseData];
    NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    
    if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"postPicture"]) {
        
        
        if ([responseDict[@"id"]integerValue]) {
            self.imageURL = [responseDict[@"id"]integerValue];
            self.uploaded = 1;
            if (self.createOrEdit == 0) {
                [self createEventFN];
            }else if (self.createOrEdit == 1){
                [self editEventFN];
                [self sendInvitations];
            }
            
        }else if (self.createOrEdit == 1){
            [self editEventFN];
            [self sendInvitations];
        }else{
            [self showAlertWithMsg:@"عفواً لم يتم إنشاء الدعوه من فضلك حاول مرة اخري" alertTag:0];
        }
        
        
    }else if([[request.userInfo objectForKey:@"key"] isEqualToString:@"createEvent"]){

        if ([responseDict[@"sucess"]integerValue] == 1) {
            
            self.eventID = [responseDict[@"id"]integerValue];
            [self sendInvitations];
            self.isEventCreated = YES;
            
        }else{
            [self.btnSave setEnabled:YES];
            [self.customAlert.closeButton setHidden:NO];
 
            [self showAlertWithMsg:@"عفواً من فضلك حاول مرة أخري" alertTag:0];
            self.isEventCreated = NO ;
            self.isUsersInvited = NO;
            
           
        }
    }else if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"editEvent"]){
        
        if (responseDict) {
            self.isEventCreated = YES;
            if (self.isEventCreated == YES && self.isUsersInvited == YES) {
                [self showAlertWithMsg:@"تم تعديل المناسبه بنجاح" alertTag:0];
                [self emptyMarkedGroups];
                [self.navigationController popViewControllerAnimated:YES];
                [self.btnSave setEnabled:YES];

            }else{
                [self sendInvitations];
            }
            
        }else{
            [self showAlertWithMsg:@"عفواً من فضلك حاول مرة أخري" alertTag:0];
            self.isEventCreated = NO ;
            self.isUsersInvited = NO;
            [self.btnSave setEnabled:YES];
            [self.customAlert.closeButton setHidden:NO];
        }
    }else if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"getAdminMsg"]){

        self.lblAdmin.text = responseDict[@"value"];
        
    }else if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"inviteUsers"]){

        self.isUsersInvited = YES;
        
        if (self.isEventCreated && self.isUsersInvited) {
            [self.creatingEvent stopAnimating];
            [self showAlertWithMsg:@"تم إنشاء الدعوه بنجاح" alertTag:1];
            [self emptyMarkedGroups];
            [self.navigationController popViewControllerAnimated:YES];
            [self.btnSave setEnabled:YES];

        }

    }else if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"getAttendees"]){
        self.previousInvitees = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        [self.gettingInvitees stopAnimating];
    
        [self refreshInvitees];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error) {
       [self showAlertWithMsg:@"عفواً حاول مرة أخري" alertTag:0];
        [self.btnSave setEnabled:YES];
        [self.customAlert.closeButton setHidden:NO];
    }
}

-(void)customAlertCancelBtnPressed{
     [self.customAlertView setHidden:YES];
    if (self.customAlert.tag == 1) {
        [self.userDefaults setObject:nil forKey:@"invitees"];
        [self.userDefaults synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)getAttendees {
    
    NSDictionary *getUsers = @{@"FunctionName":@"ViewEventAttendees" , @"inputs":@[@{@"eventID":[NSString stringWithFormat:@"%ld",(long)self.eventID],
                                                                                     @"start":[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:0]],
                                                                                     @"limit":[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:50000]]
                                                                                     }]};
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getAttendees",@"key", nil];
    
    [self postRequest:getUsers withTag:getUsersTag];
    self.gettingInvitees = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.gettingInvitees.hidesWhenStopped = YES;
    self.gettingInvitees.center = self.view.center;
    [self.gettingInvitees startAnimating];
    
}

-(void)createEventFN{
    NSDictionary *postDict   = @{@"FunctionName":@"CreateEvent" ,
                               @"inputs":@[@{@"VIP":[NSString stringWithFormat:@"%d",self.vipFlag],
                                             @"CreatorID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                             @"eventType":self.selectedType,
                                             @"subject":[NSString stringWithFormat:@"%@",self.textField.text],
                                             @"description":[NSString stringWithFormat:@"%@",self.textView.text],
                                             @"picture":[NSString stringWithFormat:@"%ld",(long)self.imageURL],
                                             @"TimeEnded":self.selectedDate,
                                                 //
                                             @"Comments":[NSString stringWithFormat:@"%d",self.commentsFlag] //checkmark
                                             }]};
//    NSLog(@"%@",postDict);
    NSMutableDictionary *createEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"createEvent",@"key", nil];
    self.btnPressed = 1;
    [self postRequest:postDict withTag:createEventTag];
//    [self.btnSave setEnabled:NO];

}

-(void)editEventFN{
    NSDictionary *postDict = @{@"FunctionName":@"editEvent" ,
                               @"inputs":@[@{ @"id":[NSString stringWithFormat:@"%ld",(long)self.eventID],
                                               @"VIP":[NSString stringWithFormat:@"%d",self.vipFlag],
                                             @"CreatorID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                             @"eventType":self.selectedType,
                                             @"subject":[NSString stringWithFormat:@"%@",self.textField.text],
                                             @"description":[NSString stringWithFormat:@"%@",self.textView.text],
                                             @"picture":[NSString stringWithFormat:@"%ld",(long)self.imageURL],
                                             @"TimeEnded":self.selectedDate,
                                             @"Comments":[NSString stringWithFormat:@"%d",self.commentsFlag] //checkmark
                                             }]};
    
//    NSLog(@"%@",postDict);
    self.btnPressed = 1;
    NSMutableDictionary *editEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"editEvent",@"key", nil];
    
    [self postRequest:postDict withTag:editEventTag];
    
    
}

-(void)sendInvitations {
    NSDictionary *inviteUsers = @{@"FunctionName":@"invite" ,
                                   @"inputs":@[@{@"EventID":[NSString stringWithFormat:@"%ld",(long)self.eventID],
                                                @"listArray":self.invitees,
                                                }]};
    NSMutableDictionary *inviteUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"inviteUsers",@"key", nil];
    [self postRequest:inviteUsers withTag:inviteUsersTag];
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"invite" sender:self];
    }
}

-(void)showAlertWithMsg:(NSString *)msg alertTag:(NSInteger )tag {
    
    [self.customAlertView setHidden:NO];
 
    self.customAlert.viewLabel.text = msg ;
    self.customAlert.tag = tag;
}

-(UIImage *)resizeImageWithImage:(UIImage *)image {
    
    CGSize newSize = CGSizeMake(200.0f, 200.0f);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Navigation Controller Delegate 

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark - Buttons

- (IBAction)btnChooseInviteesPressed:(id)sender {
    if (self.vipFlag == 1 && self.VIPPoints < 0) {
        //ALERT
    }else{
        [self performSegueWithIdentifier:@"invite" sender:self];
    }
    
}

- (IBAction)btnChoosePicPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    
    }
    
}

- (IBAction)btnChooseInvitation:(id)sender {
    [self performSegueWithIdentifier:@"invitationTypes" sender:self];
}

- (IBAction)btnSubmitPressed:(id)sender {

        if ((self.textField.text.length != 0) && (self.textView.text.length != 0) && (self.selectedDate.length > 0) && self.createOrEdit == 0 && self.vipFlag != -1 && self.selectedType != nil) {
            
            
            if (self.flag == 1) {
                if (self.allowCreation == true) {
                    
                    [self.customAlertView setHidden:NO];
                    
                    
                    self.customAlert.viewLabel.text = @"من فضلك إنتظر حتي يتم إنشاء الدعوة" ;
                    [self.customAlert.closeButton setHidden:YES];
                    
                    self.creatingEvent = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                    self.creatingEvent.hidesWhenStopped = YES;
                    self.creatingEvent.center = CGPointMake(self.customAlertView.frame.size.width/2, self.customAlert.frame.origin.y - 40);
                    [self.customAlertView addSubview:self.creatingEvent];
                    [self.creatingEvent startAnimating];
                    
                    [self.btnSave setEnabled:NO];
                    
                    NSMutableDictionary *postPictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"postPicture",@"key", nil];
                    [self postPictureWithTag:postPictureTag];
                    
                }
                
            }else {
                [self.btnSave setEnabled:YES];
                [self.customAlert.closeButton setHidden:NO];
                [self showAlertWithMsg:@"من فضلك تأكد من اختيار صورة للدعوه" alertTag:0];
                
            }
            
        } else if (self.createOrEdit == 1) {
            
                [self.customAlertView setHidden:NO];
                
                self.customAlert.viewLabel.text = @"من فضلك إنتظر حتي يتم تعديل الدعوة" ;
                [self.customAlert.closeButton setHidden:YES];
                
                self.creatingEvent = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                self.creatingEvent.hidesWhenStopped = YES;
                self.creatingEvent.center = CGPointMake(self.customAlertView.frame.size.width/2, self.customAlert.frame.origin.y - 40);
                [self.customAlertView addSubview:self.creatingEvent];
                [self.creatingEvent startAnimating];
                
                [self.btnSave setEnabled:NO];
            if (self.flag == 1) {
                NSMutableDictionary *postPictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"postPicture",@"key", nil];
                [self postPictureWithTag:postPictureTag];
            }else{
                [self editEventFN];
            }
            
            
        }else{
            [self.btnSave setEnabled:YES];
            [self.customAlert.closeButton setHidden:NO];
            [self showAlertWithMsg:@"من فضلك تأكد من تكمله جميع البيانات" alertTag:0];
        }

    
    
}

- (IBAction)btnMarkCommentsPressed:(id)sender {
    self.commentsFlag = !(self.commentsFlag);
    if (self.commentsFlag == 1) {
        [self.btnMarkComments setTitle:@"\u2713 السماح بالتعليقات" forState:UIControlStateNormal];
    }else{
        [self.btnMarkComments setTitle:@"\u274F  السماح بالتعليقات" forState:UIControlStateNormal];
    }

}


- (IBAction)RadioButtonPressed:(UIButton *)sender {
    //self.invitees.count > 0 &&
    
    if ( self.createOrEdit == 0) {
        if (sender.tag == 0) { // VIP Pressed
            if (self.vipFlag == 1) {
                self.vipFlag = -1;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.unChecked;
                self.VIPPoints += 1;
                self.VIPPoints += self.invitees.count;
                [self updateStoredVIPPointsNumber];

            }else{
                if (self.VIPPoints >= (self.invitees.count + 1)) {
                    self.VIPPoints -= 1;
                    self.vipFlag = 1;
                    self.VIPRadioButton.text = self.checked;
                    self.normalRadioButton.text = self.unChecked;
                    self.VIPPoints = self.VIPPoints - self.invitees.count;
                    [self updateStoredVIPPointsNumber];

                }else{
//                    UIAlertView *alertview // Buy now
                    [self showAlertWithMsg:@"لا يوجد لديك دعوات VIP كافية" alertTag:0];

                }
            }
        }else if (sender.tag == 1){ // Normal Pressed
            if (self.vipFlag == 0) {
                self.vipFlag = -1;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.unChecked;
                
            }else if (self.vipFlag == 1){
                self.vipFlag = 0;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.checked;
                self.VIPPoints += 1;
                self.VIPPoints += self.invitees.count;
                [self updateStoredVIPPointsNumber];
//                NSLog(@"VIP Points %ld ",(long)self.VIPPoints);
//                NSLog(@"Invitees Points %lu ",(unsigned long)self.invitees.count);
            }else{
                self.vipFlag = 0;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.checked;
  
            }
            
        }
    }else{
        if (sender.tag == 0) { // VIP Pressed
            if (self.vipFlag == 1) {
               // self.vipFlag = -1;
                self.VIPRadioButton.text = self.checked;
                self.normalRadioButton.text = self.unChecked;
                //self.VIPPoints += 1;
                //[self updateStoredVIPPointsNumber];
            }else{
                if (self.VIPPoints >= (self.invitees.count + self.previousInvitees.count + 1)) {
                    self.VIPPoints -= 1;
                    self.vipFlag = 1;
                    self.VIPRadioButton.text = self.checked;
                    self.normalRadioButton.text = self.unChecked;
                    self.VIPPoints = self.VIPPoints - (self.invitees.count + self.previousInvitees.count) ;
                    [self updateStoredVIPPointsNumber];
                }else{
                    //                    UIAlertView *alertview // Buy now
                    [self showAlertWithMsg:@"لا يوجد لديك دعوات VIP كافية" alertTag:0];
                    
                }
                
                
            }
        }else if (sender.tag == 1 ){ // Normal Pressed
            if (self.vipFlag == 0) {
                self.vipFlag = -1;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.unChecked;
                
            }else if(self.vipFlag == 1){
                //self.vipFlag = 0;
                self.VIPRadioButton.text = self.checked;
                self.normalRadioButton.text = self.unChecked;
                //self.VIPPoints += 1;
                //[self updateStoredVIPPointsNumber];
            }else{
                
                self.vipFlag = 0;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.checked;
            }
            
            //        NSLog(@"%ld",(long)self.VIPPoints);
        }else if (sender.tag == 0 && self.createOrEdit == 1 && self.vipFlag == 1){
            if (self.allowEditing == YES) {
                self.vipFlag = -1;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.unChecked;
                
                
            }else{
                //do nothing
            }
        }else if (sender.tag == 0 && self.createOrEdit == 1 && self.vipFlag == 0){
            self.allowEditing = YES;
            self.vipFlag = 1;
            self.VIPRadioButton.text = self.checked;
            self.normalRadioButton.text = self.unChecked;
            
            
        }else if (sender.tag == 1 && self.createOrEdit == 1 ){
            
            if (self.vipFlag == 0 && self.allowEditing == YES) {
                self.vipFlag = -1;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.unChecked;
                
                
            }else if (self.vipFlag == 1 && self.allowEditing == YES){
                self.vipFlag = 0;
                self.VIPRadioButton.text = self.unChecked;
                self.normalRadioButton.text = self.checked;
                
                
            }else{
                //do nothing
            }
        }
    }
    
}


- (IBAction)datePickerAction:(id)sender {
    [self performSegueWithIdentifier:@"chooseDate" sender:self];
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.userDefaults setObject:nil forKey:@"invitees"];
    [self.userDefaults synchronize];
    [self emptyMarkedGroups];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)updateStoredVIPPointsNumber{
    [self.userDefaults setInteger:self.VIPPoints forKey:@"VIPPoints"];
    [self.userDefaults synchronize];
}

-(void)emptyMarkedGroups{
    [self.userDefaults removeObjectForKey:@"markedGroups"];
    [self.userDefaults synchronize];
}

@end



