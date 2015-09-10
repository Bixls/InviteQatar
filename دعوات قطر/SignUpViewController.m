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
#import "NetworkConnection.h"


static void *signUpContext = &signUpContext;
static void *uploadImageContext = &uploadImageContext;

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseImage;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseGroup;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;

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
@property (nonatomic,strong) NetworkConnection *uploadImageConn;
@property (nonatomic,strong) NetworkConnection *signUpConn;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.flag = 0;
    self.uploaded =0;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //self.selectedGroup = @{@"id":@"default"} ;
    
    self.activateFlag = [self.userDefaults integerForKey:@"activateFlag"];
   // self.viewHeight.constant = self.view.bounds.size.height - 35;
    self.uploadImageConn = [[NetworkConnection alloc]init];
    self.signUpConn = [[NetworkConnection alloc]init];
    
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.signUpConn addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:signUpContext];
    [self.uploadImageConn addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:uploadImageContext];
    
    if (self.offlinePic == 1) {
        NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
        [self.uploadImageConn postPicturewithTag:pictureTag uploadImage:self.profilePicture.image];
        //[self postPicturewithTag:pictureTag];
        self.offlinePic = 0;
    }
}

-(void)viewWillDisappear:(BOOL)animated{

    [self.signUpConn removeObserver:self forKeyPath:@"response" context:signUpContext];
    [self.uploadImageConn removeObserver:self forKeyPath:@"response" context:uploadImageContext];
    
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

#pragma mark - KVO Methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
  
    if (context == signUpContext) {
        if ([keyPath isEqualToString:@"response"]) {
            
            NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
            self.responseDictionary =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            NSLog(@"%@",self.responseDictionary);
            NSInteger success = [self.responseDictionary[@"sucess"]integerValue];
            if (success == 1) {
                self.userID = [self.responseDictionary[@"id"]integerValue];
                NSLog(@"USER ID %d",self.userID);
                [self.userDefaults setInteger:self.userID forKey:@"userID"];
                [self.userDefaults synchronize];
                self.activateFlag = 1;
                [self.userDefaults setInteger:self.activateFlag forKey:@"activateFlag"];
                
                [self.userDefaults synchronize];
                
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"شكراً" message:@"تم إرسال طلب التسجيل بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
                [alertView show];
                [self performSegueWithIdentifier:@"activateAccount" sender:self];
                
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"الإسم أو رقم الهاتف موجودون بالفعل" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
            
        }
    }else if (context == uploadImageContext){
        if ([keyPath isEqualToString:@"response"]) {
            NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
            NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            NSLog(@"%@",responseDict);
            self.imageURL = responseDict[@"id"];
            self.uploaded =1;
        }
    }
    
    
}

#pragma mark - Delegate Methods

-(void)selectedGroup:(NSDictionary *)group {
    self.selectedGroup = group;
    [self.btnChooseGroup setTitle:self.selectedGroup[@"name"] forState:UIControlStateNormal];
//    NSLog(@"%@",group);
    
}

-(void)selectedPicture:(UIImage *)image{
    self.selectedImage = image;
    self.profilePicture.image = self.selectedImage;
//    NSLog(@"%@",image);
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
        
    }else if ([segue.identifier isEqualToString:@"activateAccount"]){
        ConfirmationViewController *confirmController = segue.destinationViewController;
        
    }

}


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
        
        [self.uploadImageConn postPicturewithTag:pictureTag uploadImage:self.profilePicture.image];
//        [self postPicturewithTag:pictureTag];
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
    
    NSString *groupID = (NSString *)self.selectedGroup[@"id"];
    
    if ((self.nameField.text.length != 0) && (self.mobileField.text.length != 0 )&& (self.passwordField.text.length != 0) && (groupID.length > 0)) {
        if (self.flag == 1 && self.uploaded == 1 ) {
            
            NSDictionary *postDict = @{@"FunctionName":@"Register" ,
                                       @"inputs":@[@{@"name":self.nameField.text,
                                                     @"Mobile":self.mobileField.text,
                                                     @"password":self.passwordField.text,
                                                     @"groupID":(NSString *)self.selectedGroup[@"id"],
                                                     @"ProfilePic":self.imageURL}]};
            
            NSMutableDictionary *registerTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"registerTag",@"key", nil];
            
            //                [self postRequest:postDict withTag:registerTag];
            [self.signUpConn postRequest:postDict withTag:registerTag];
            
            
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



