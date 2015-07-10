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

@interface CreateEventViewController ()

@property (nonatomic,strong)NSArray *invitationTypes;
@property (nonatomic)NSInteger selectedType;
@property (nonatomic) int commentsFlag;
@property (nonatomic) int vipFlag;
@property (strong,nonatomic) ASIFormDataRequest *imageRequest;
@property (strong,nonatomic) NSString *imageURL;
@property (strong , nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic) int flag;
@property (nonatomic) int uploaded;
@property(nonatomic,strong)NSDictionary *selectedCategory;
@property (nonatomic,strong) NSString *selectedDate;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID  = [self.userDefaults integerForKey:@"userID"];
    //NSLog(@"%ld",(long)self.userID);
    //self.invitationTypes = @[@"الأعراس",@"العزاء",@"تخرج",@"تهنيئه",@"مناسبات"];
    self.commentsFlag = 0;
    self.vipFlag = 0;
    [self.btnMarkComments setTitle:@"السماح بالتعليقات \u274F" forState:UIControlStateNormal];
    [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
    self.imageURL = @"default";
    
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"invitationTypes"]) {
        ChooseTypeViewController *chooseTypeController = segue.destinationViewController;
        chooseTypeController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"chooseDate"]){
        ChooseDateViewController *chooseDateController = segue.destinationViewController;
        chooseDateController.delegate = self;
    }
}

#pragma mark - ChooseType ViewController Delegate
-(void)selectedCategory:(NSDictionary *)category{
    self.selectedCategory = category;
    [self.btnChooseType setTitle:category[@"catName"] forState:UIControlStateNormal];
}

#pragma mark - ChooseDate ViewController Delegate 
-(void)selectedDate:(NSString *)date{
    self.selectedDate = date;
    [self.btnChooseDate setTitle:self.selectedDate forState:UIControlStateNormal];
}


#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView Delegate Methods

-(void)textViewDidBeginEditing:(UITextView *)textView {
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"تم" style:UIBarButtonItemStyleDone target:self action:@selector(removeKeyboard)];

    [self.navigationItem setRightBarButtonItem:doneBtn];
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
        self.imagePicker.image = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        NSMutableDictionary *postPictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"postPicture",@"key", nil];
        [self postPictureWithTag:postPictureTag];
        self.flag = 1;
    }
   
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
     [self.btnChoosePic setTitle:@"تحميل الصورة" forState:UIControlStateNormal];
    
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
    [self.imageRequest addRequestHeader:@"Accept" value:@"application/json"];
    [self.imageRequest addRequestHeader:@"content-type" value:@"application/json"];
    self.imageRequest.allowCompressedResponse = NO;
    
    
    self.imageRequest.useCookiePersistence = NO;
    self.imageRequest.shouldCompressRequestBody = NO;
    self.imageRequest.userInfo = dict;
    [self.imageRequest setPostValue:@"6" forKey:@"id"];
    [self.imageRequest setPostValue:@"user" forKey:@"type"];
    [self.imageRequest addData:[NSData dataWithData:UIImageJPEGRepresentation(self.imagePicker.image, 0.9)] withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"fileToUpload"];
    [self.imageRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    //NSString *responseString = [request responseString];
   
    NSData *responseData = [request responseData];
    NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    
    if ([[request.userInfo objectForKey:@"key"] isEqualToString:@"postPicture"]) {
        self.imageURL = responseDict[@"url"];
        NSLog(@"%@",self.imageURL);
        self.uploaded = 1;
    }else{
        if ([responseDict[@"success"]integerValue]==1) {
            NSLog(@"Event Created !");
            NSLog(@"%@",responseDict);
        }
        NSLog(@"%d",[[responseDict objectForKey:@"success"]intValue]);
    }
    NSLog(@"%@",responseDict);

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}




#pragma mark - Buttons

- (IBAction)btnChoosePicPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        [self.btnChoosePic setTitle:@" " forState:UIControlStateNormal];
    
    }
    
}

- (IBAction)btnChooseInvitation:(id)sender {
    [self performSegueWithIdentifier:@"invitationTypes" sender:self];
}

- (IBAction)btnSubmitPressed:(id)sender {
    
    if ((self.textField.text.length != 0) && (self.textView.text.length != 0) && (self.uploaded == 1) && (self.selectedDate.length > 0)) {
        if (self.flag == 1 && self.uploaded == 1 ) {
            
            NSDictionary *postDict = @{@"FunctionName":@"CreateEvent" ,
                                       @"inputs":@[@{@"VIP":[NSString stringWithFormat:@"%d",self.vipFlag],
                                                     @"CreatorID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                     @"eventType":[NSString stringWithFormat:@"%ld",(long)self.selectedType],
                                                     @"subject":[NSString stringWithFormat:@"%@",self.textField.text],
                                                     @"description":[NSString stringWithFormat:@"%@",self.textView.text],
                                                     @"picture":self.imageURL,
                                                     @"TimeEnded":self.selectedDate,
                                                     @"Comments":[NSString stringWithFormat:@"%d",self.commentsFlag] //checkmark
                                                     }]};

            NSLog(@"%@",postDict);
            NSMutableDictionary *createEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"createEvent",@"key", nil];
            
            [self postRequest:postDict withTag:createEventTag];
            
            
        }else if (self.flag == 1){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك انتظر حتي يتم رفع الصورة" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }else {
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من اختيار صورة شخصيه او رمزيه" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        
    } else{
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من تكمله جميع البيانات" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }

    
    
    
    
}

- (IBAction)btnMarkCommentsPressed:(id)sender {
    self.commentsFlag = !(self.commentsFlag);
    if (self.commentsFlag == 1) {
        [self.btnMarkComments setTitle:@"السماح بالتعليقات \u2713" forState:UIControlStateNormal];
    }else{
        [self.btnMarkComments setTitle:@"السماح بالتعليقات \u274F" forState:UIControlStateNormal];
    }

    
}

- (IBAction)btnMarkVipPressed:(id)sender {
    self.vipFlag = !(self.vipFlag);
    if (self.vipFlag == 1) {
        [self.btnMarkVIP setTitle:@"\u2713 VIP" forState:UIControlStateNormal];
    }else{
        [self.btnMarkVIP setTitle:@"\u274F VIP" forState:UIControlStateNormal];
    }

}

- (IBAction)datePickerAction:(id)sender {
    [self performSegueWithIdentifier:@"chooseDate" sender:self];
}


@end



