//
//  SignUpViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SignUpViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ConfirmationViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseImage;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseGroup;

@property (strong,nonatomic)UIActivityIndicatorView * spinner;
@property (strong,nonatomic) NSDictionary *selectedGroup;
@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (strong,nonatomic) ASIFormDataRequest *imageRequest;
@property (nonatomic) int flag;
@property (nonatomic) int uploaded;
@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic) int userID;
@property (nonatomic) NSInteger offlinePic;
@property (nonatomic) int activateFlag;
@property (nonatomic,strong) NSDictionary *responseDictionary;
@property (nonatomic,strong) UIImage *selectedImage;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flag = 0;
    self.uploaded =0;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.selectedGroup = @{@"id":@"default"} ;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
//    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [self.spinner setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2.0, [[UIScreen mainScreen] bounds].size.height/2.0)];
//    [self.view addSubview:self.spinner];
    [self.navigationItem setHidesBackButton:YES];

    self.activateFlag = [self.userDefaults integerForKey:@"activateFlag"];
    
}

-(void)viewDidAppear:(BOOL)animated{
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.view.backgroundColor = [UIColor blackColor];
    if (self.offlinePic == 1) {
        NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
        [self postPicturewithTag:pictureTag];
        self.offlinePic = 0;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

-(void)didReceiveMemoryWarning{
    //
}

-(void)selectedGroup:(NSDictionary *)group {
    self.selectedGroup = group;
    [self.btnChooseGroup setTitle:self.selectedGroup[@"name"] forState:UIControlStateNormal];
    NSLog(@"%@",group);
    
}

-(void)selectedPicture:(UIImage *)image{
    self.selectedImage = image;
    self.profilePicture.image = self.selectedImage;
    NSLog(@"%@",image);
    [self.btnChooseImage setImage:nil forState:UIControlStateNormal];
    
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.offlinePic = 1 ;
    self.flag = 1;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chooseGroupSegue"]) {
        chooseGroupViewController *chooseGroupController = segue.destinationViewController;
        chooseGroupController.flag = 0;
        chooseGroupController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"offlinePic"]){
        OfflinePicturesViewController *offlinePicturesController = segue.destinationViewController;
        offlinePicturesController.delegate = self;
        
    }

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

-(void)postPicturewithTag:(NSMutableDictionary *)dict{
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
//    [self.imageRequest setPostValue:@"user" forKey:@"type"];
    NSLog(@"%@",self.profilePicture.image);
    
    NSData *testData = [NSData dataWithData:UIImageJPEGRepresentation(self.profilePicture.image, 1.0)];
    
    //NSLog(@"%@ ",testData);
    
    [self.imageRequest addData:[NSData dataWithData:UIImageJPEGRepresentation(self.profilePicture.image,1.0)] withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"fileToUpload"];
    [self.imageRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    //NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"pictureTag"]) {
        NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",responseDict);
        self.imageURL = responseDict[@"id"];
        self.uploaded =1;
    }else {
        self.responseDictionary =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",self.responseDictionary);
        self.userID = [self.responseDictionary[@"id"]integerValue];
        NSLog(@"USER ID %d",self.userID);
        [self.userDefaults setInteger:self.userID forKey:@"userID"];
        [self.userDefaults synchronize];
        self.activateFlag = 1;
        [self.userDefaults setInteger:self.activateFlag forKey:@"activateFlag"];
        [self.userDefaults setInteger:1 forKey:@"Guest"];
        [self.userDefaults setInteger:1 forKey:@"signedIn"];
        [self.userDefaults synchronize];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    if ([key isEqualToString:@"registerTag"]) {
         NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSInteger success = [responseDict[@"success"]integerValue];
        if (success == 0) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"شكراً" message:@"تم إرسال طلب التسجيل بنجاح،من فضلك انتظر رساله التفعيل في خلال يوم" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
    }
   
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

//-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

#pragma mark - Textfield delegate method 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%@",textField.text);
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Image Picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.profilePicture.image = [self imageWithImage:image scaledToSize:CGSizeMake(150 , 150)];
        //
        [self.btnChooseImage setImage:nil forState:UIControlStateNormal];
        
        NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
        [self postPicturewithTag:pictureTag];
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

#pragma mark - Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet * )actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            imagePicker.allowsEditing = NO;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }else if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"offlinePic" sender:self];
    }
}

#pragma mark - Buttons 

- (IBAction)btnChooseImagePressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"ضع صورتك الشخصية أو اختار صورة رمزية" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"صورة شخصية",@"صورة رمزية", nil];
    [actionSheet showInView:self.view];
    
    }


- (IBAction)btnSignUpPressed:(id)sender {
    
    
//    if (self.activateFlag == 0) {
        if ((self.nameField.text.length != 0) && (self.mobileField.text.length != 0 )&& (self.passwordField.text.length != 0) && (self.selectedGroup != nil)) {
            if (self.flag == 1 && self.uploaded == 1 ) {
                
                NSDictionary *postDict = @{@"FunctionName":@"Register" ,
                                           @"inputs":@[@{@"name":self.nameField.text,
                                                         @"Mobile":self.mobileField.text,
                                                         @"password":self.passwordField.text,
                                                         @"groupID":(NSString *)self.selectedGroup[@"id"],
                                                         @"ProfilePic":self.imageURL}]};
                
                NSMutableDictionary *registerTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"registerTag",@"key", nil];
                
                [self postRequest:postDict withTag:registerTag];
                
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

//    }
    
}

- (IBAction)btnBackgroundPressed:(id)sender {
    if ([self.mobileField isFirstResponder]) {
        [self.mobileField resignFirstResponder];
    }
    if ([self.nameField isFirstResponder]) {
        [self.nameField resignFirstResponder];
    }
    if ([self.passwordField isFirstResponder]) {
        [self.passwordField resignFirstResponder];
    }
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end



