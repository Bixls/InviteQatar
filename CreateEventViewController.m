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
@property (strong,nonatomic) NSString *imageURL;
@property (strong , nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic) int flag;
@property (nonatomic) int uploaded;
@property (nonatomic) NSInteger btnPressed;
@property (nonatomic) NSInteger continueFlag;
@property(nonatomic,strong)NSDictionary *selectedCategory;
@property(nonatomic,strong)NSDictionary *createdEvent;
@property (nonatomic,strong) NSString *selectedDate;

@property (nonatomic,strong) UIImage *selectedImage;
@property (nonatomic,strong) NSString *normalUnchecked;
@property (nonatomic,strong) NSString *normalChecked;
@property (nonatomic,strong) NSString *unChecked;
@property (nonatomic,strong) NSString *checked;
@property (nonatomic) NSInteger VIPPoints;
@property (nonatomic,strong) NetworkConnection *adminMgsConnection;
@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    [self.textView setReturnKeyType:UIReturnKeyDone];
    self.textView.delegate = self;
    self.textField.delegate = self;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID  = [self.userDefaults integerForKey:@"userID"];
    self.VIPPoints = [self.userDefaults integerForKey:@"VIPPoints"];
    //NSLog(@"%ld",(long)self.userID);
    self.commentsFlag = 0;
    self.vipFlag = -1;
    self.unChecked =@"⚪️";
    self.checked = @"🔘";
    
    self.VIPRadioButton.text = self.unChecked;
    self.normalRadioButton.text = self.checked;
    self.vipFlag = 0;
    
    
//    [self.btnMarkNormal setTitle:self.normalUnchecked forState:UIControlStateNormal];
    [self.btnMarkComments setTitle:@"\u274F  السماح بالتعليقات" forState:UIControlStateNormal];
//    [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
    
    self.imageURL = @"default";
    if (self.event != nil && self.createOrEdit ==1) {
        self.vipFlag = [self.event[@"VIP"]integerValue];
        NSLog(@"%d",self.vipFlag);
        self.selectedType = self.event[@"eventType"];
        self.textField.text = self.event[@"subject"];
        self.textView.text = self.event[@"description"];
        self.selectedDate = self.event[@"TimeEnded"];
        self.commentsFlag = [self.event[@"comments"]integerValue];
        self.imageURL = self.event[@"picture"];
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
    
//    [self.navigationItem setHidesBackButton:YES];
    self.adminMgsConnection = [[NetworkConnection alloc]init];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.adminMgsConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:adminMsgContext];
    [self.adminMgsConnection getCreateEventAdminMsg];
//    [self getCreateEventAdminMsg];
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
            //
        }
    }
}

//-(void)getCreateEventAdminMsg {
//    NSDictionary *getAdminMsg = @{@"FunctionName":@"getString" , @"inputs":@[@{@"name":@"createEvent",
//                                                                             }]};
//    NSMutableDictionary *getAdminMsgTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getAdminMsg",@"key", nil];
//    
//    [self postRequest:getAdminMsg  withTag:getAdminMsgTag];
//}

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




//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    [textField resignFirstResponder];
//}

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
        NSLog(@"Return pressed");
        [textView resignFirstResponder];
    } else {
        NSLog(@"Other pressed");
    }
    return YES;
}


-(void)removeKeyboard{
    [self.textView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    NSLog(@"%@",self.textView.text);
}

#pragma mark - Image Picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.selectedImage = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        NSMutableDictionary *postPictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"postPicture",@"key", nil];
        [self postPictureWithTag:postPictureTag];
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
        NSLog(@"%@",responseDict);
        self.imageURL = responseDict[@"id"];
        self.uploaded = 1;
    }else if([[request.userInfo objectForKey:@"key"] isEqualToString:@"createEvent"]){
         NSLog(@"%@",responseDict);
        if ([responseDict[@"sucess"]integerValue] == 1) {
            self.eventID = [responseDict[@"id"]integerValue];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"هل تريد دعوة الآخرين الآن ؟ " delegate:self cancelButtonTitle:@"لا" otherButtonTitles:@"نعم", nil];
            [alertView show];
        }
        /*
         UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@" تم حفظ المناسبة من فضلك انتظر الموافقة عليها في خلال اربعة و عشرين ساعة" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
         [alertView show];
         [self.navigationController popToRootViewControllerAnimated:YES];

         */
    }else if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"editEvent"]){
        if (responseDict) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"تم تعديل المناسبه بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"getAdminMsg"]){
        NSLog(@"%@",responseDict);
        self.lblAdmin.text = responseDict[@"value"];
    }
  
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error) {
        if (self.btnPressed == 1) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"لم يتم عمل مناسبه جديده" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
            self.btnPressed = 0;
            
        }
    }
    NSLog(@"%@",error);
}

-(void)createEventFN{
    NSDictionary *postDict   = @{@"FunctionName":@"CreateEvent" ,
                               @"inputs":@[@{@"VIP":[NSString stringWithFormat:@"%d",self.vipFlag],
                                             @"CreatorID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                             @"eventType":self.selectedType,
                                             @"subject":[NSString stringWithFormat:@"%@",self.textField.text],
                                             @"description":[NSString stringWithFormat:@"%@",self.textView.text],
                                             @"picture":self.imageURL,
                                             @"TimeEnded":self.selectedDate,
                                                 //
                                             @"Comments":[NSString stringWithFormat:@"%d",self.commentsFlag] //checkmark
                                             }]};
    NSLog(@"%@",postDict);
    NSMutableDictionary *createEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"createEvent",@"key", nil];
    self.btnPressed = 1;
    [self postRequest:postDict withTag:createEventTag];

}

-(void)editEventFN{
    NSDictionary *postDict = @{@"FunctionName":@"editEvent" ,
                               @"inputs":@[@{ @"id":[NSString stringWithFormat:@"%ld",(long)self.eventID],
                                               @"VIP":[NSString stringWithFormat:@"%d",self.vipFlag],
                                             @"CreatorID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                             @"eventType":self.selectedType,
                                             @"subject":[NSString stringWithFormat:@"%@",self.textField.text],
                                             @"description":[NSString stringWithFormat:@"%@",self.textView.text],
                                             @"picture":self.imageURL,
                                             @"TimeEnded":self.selectedDate,
                                             @"Comments":[NSString stringWithFormat:@"%d",self.commentsFlag] //checkmark
                                             }]};
    
    NSLog(@"%@",postDict);
    self.btnPressed = 1;
    NSMutableDictionary *editEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"editEvent",@"key", nil];
    
    [self postRequest:postDict withTag:editEventTag];
    
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"invite" sender:self];
    }
}

#pragma mark - Navigation Controller Delegate 

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark - Buttons

- (IBAction)btnChooseInviteesPressed:(id)sender {
    if (self.vipFlag == 1 && (self.VIPPoints == 0 || self.VIPPoints == 1)) {
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

        if ((self.textField.text.length != 0) && (self.textView.text.length != 0) && (self.uploaded == 1) && (self.selectedDate.length > 0) && self.createOrEdit == 0 && self.selectedType.length > 0) {
            if (self.flag == 1 && self.uploaded == 1 ) {
                
                [self createEventFN];
                
                
            }else if (self.flag == 1){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك انتظر حتي يتم رفع الصورة" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
                [alertView show];
            }else {
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من اختيار صورة شخصيه او رمزيه" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
            
        } else if (self.createOrEdit == 1) {
            
            if (self.flag == 1 && self.uploaded == 1 ) {
                
                [self editEventFN];
                
                
            }else if (self.flag == 1){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك انتظر حتي يتم رفع الصورة" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
                [alertView show];
            }else {
                [self editEventFN];
            }
            
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من تكمله جميع البيانات" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
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
    
    if (sender.tag == 0 && self.createOrEdit == 0) {
        if (self.vipFlag == 1) {
            self.vipFlag = -1;
//            [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
            self.VIPRadioButton.text = self.unChecked;
//            [self.btnMarkNormal setTitle:self.normalUnchecked forState:UIControlStateNormal];
            self.normalRadioButton.text = self.unChecked;
        }else{
            self.vipFlag = 1;
//            [self.btnMarkVIP setTitle:@"\u2713 VIP" forState:UIControlStateNormal];
            self.VIPRadioButton.text = self.checked;
            self.normalRadioButton.text = self.unChecked;
//            [self.btnMarkNormal setTitle:self.normalUnchecked forState:UIControlStateNormal];
        }

    }else if (sender.tag == 1 && self.createOrEdit == 0){
        if (self.vipFlag == 0) {
            self.vipFlag = -1;
            self.VIPRadioButton.text = self.unChecked;
            self.normalRadioButton.text = self.unChecked;
//            [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
//            [self.btnMarkNormal setTitle:self.normalUnchecked forState:UIControlStateNormal];
        }else{
            self.vipFlag = 0;
            self.VIPRadioButton.text = self.unChecked;
            self.normalRadioButton.text = self.checked;
//            [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
//            [self.btnMarkNormal setTitle:self.normalChecked forState:UIControlStateNormal];
        }

        
    }else if (sender.tag == 0 && self.createOrEdit == 1 && self.vipFlag == 1){
        if (self.allowEditing == YES) {
            self.vipFlag = -1;
            self.VIPRadioButton.text = self.unChecked;
            self.normalRadioButton.text = self.unChecked;
//            [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
//            [self.btnMarkNormal setTitle:self.normalUnchecked forState:UIControlStateNormal];
        }else{
            //do nothing
        }
    }else if (sender.tag == 0 && self.createOrEdit == 1 && self.vipFlag == 0){
        self.allowEditing = YES;
        self.vipFlag = 1;
        self.VIPRadioButton.text = self.checked;
        self.normalRadioButton.text = self.unChecked;
//        [self.btnMarkVIP setTitle:@"\u2713 VIP" forState:UIControlStateNormal];
//        [self.btnMarkNormal setTitle:self.normalUnchecked forState:UIControlStateNormal];
    }else if (sender.tag == 1 && self.createOrEdit == 1 ){
        
        if (self.vipFlag == 0 && self.allowEditing == YES) {
            self.vipFlag = -1;
            self.VIPRadioButton.text = self.unChecked;
            self.normalRadioButton.text = self.unChecked;
//            [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
//            [self.btnMarkNormal setTitle:self.normalUnchecked forState:UIControlStateNormal];
        }else if (self.vipFlag == 1 && self.allowEditing == YES){
            self.vipFlag = 0;
            self.VIPRadioButton.text = self.unChecked;
            self.normalRadioButton.text = self.checked;
//            [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
//            [self.btnMarkNormal setTitle:self.normalChecked forState:UIControlStateNormal];
        }else{
            //do nothing
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
    [self.navigationController popViewControllerAnimated:YES];
}

@end



