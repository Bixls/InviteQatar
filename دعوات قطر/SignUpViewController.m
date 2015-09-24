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
#import <URBNAlert/URBNAlert.h>

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
@property (weak, nonatomic) IBOutlet customAlertView *customAlert;
@property (weak, nonatomic) IBOutlet UIView *customAlertView;


@property (strong,nonatomic)UIActivityIndicatorView * spinner;
@property (strong,nonatomic) NSDictionary *selectedGroup;
@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (strong,nonatomic) ASIFormDataRequest *imageRequest;
@property (nonatomic) int flag;
@property (nonatomic) int uploaded;
@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger offlinePic;
@property (nonatomic) int activateFlag;
@property (nonatomic,strong) NSDictionary *responseDictionary;
@property (nonatomic,strong) UIImage *selectedImage;

@property (nonatomic,strong) NetworkConnection *uploadImageConn;
@property (nonatomic,strong) NetworkConnection *signUpConn;
@property (nonatomic) NSInteger alertTag;

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
    
    self.customAlert.delegate = self;
    [self.customAlertView setHidden:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self initiateSignUp];

    if (self.offlinePic == 1) {
        [self initiateUploadImage];
        NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
        [self.uploadImageConn postPicturewithTag:pictureTag uploadImage:self.profilePicture.image];
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

#pragma mark - Completion Handlers

-(void)initiateSignUp{
    self.signUpConn = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        
        self.responseDictionary =[NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        NSInteger success = [self.responseDictionary[@"sucess"]boolValue];
        if (success == true) {
            NSDictionary *data = self.responseDictionary[@"data"];
            self.userID = [data[@"id"]integerValue];

            [self.userDefaults setInteger:self.userID forKey:@"userID"];
            [self.userDefaults synchronize];
            self.activateFlag = 1;
            [self.userDefaults setInteger:self.activateFlag forKey:@"activateFlag"];
            [self.userDefaults synchronize];
            
            [self showAlertWithMsg:@"تم إرسال طلب التسجيل بنجاح" alertTag:1];
            
        }else{
            [self showAlertWithMsg:@"الإسم أو رقم الهاتف موجودون بالفعل" alertTag:0];
            
        }

    }];
}

-(void)initiateUploadImage {
    self.uploadImageConn = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        self.imageURL = responseDict[@"id"];
        self.uploaded =1;
    }];
}

#pragma mark - Alert View Methods

-(void)showAlertWithMsg:(NSString *)msg alertTag:(NSInteger )tag {

    [self.customAlertView setHidden:NO];
    self.customAlert.viewLabel.text = msg ;
    self.customAlert.tag = tag;
}



#pragma mark - Delegate Methods

-(void)selectedGroup:(NSDictionary *)group {
    self.selectedGroup = group;
    [self.btnChooseGroup setTitle:self.selectedGroup[@"name"] forState:UIControlStateNormal];
    
}

-(void)selectedPicture:(UIImage *)image{
    self.selectedImage = image;
    self.profilePicture.image = self.selectedImage;
    [self.btnChooseImage setImage:nil forState:UIControlStateNormal];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.offlinePic = 1 ;
    self.flag = 1;
}

-(void)customAlertCancelBtnPressed{
    [self.customAlertView setHidden:YES];
    if (self.customAlert.tag == 1) {
        [self performSegueWithIdentifier:@"activateAccount" sender:self];
        self.customAlert.tag = 0;
    }
    
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

    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Image Picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

        self.profilePicture.image = [self resizeImageWithImage:image];
        
        [self.btnChooseImage setImage:nil forState:UIControlStateNormal];
        
        [self initiateUploadImage];
        NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
        [self.uploadImageConn postPicturewithTag:pictureTag uploadImage:self.profilePicture.image];

        self.flag = 1;
    }
    
    
}

-(UIImage *)resizeImageWithImage:(UIImage *)image {
    
    CGSize newSize = CGSizeMake(200.0f, 200.0f);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

#pragma mark - Navigation Controller Delegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark - Buttons

- (IBAction)btnChooseImagePressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"ضع صورتك الشخصية أو اختار صورة رمزية" delegate:self cancelButtonTitle:@"إغلاق" destructiveButtonTitle:nil otherButtonTitles:@"صورة شخصية",@"صورة رمزية", nil];
    [actionSheet showInView:self.view];
    
    }


- (IBAction)btnSignUpPressed:(id)sender {
    
    NSString *groupID = (NSString *)self.selectedGroup[@"id"];
    
    if ((self.nameField.text.length != 0) && (self.mobileField.text.length != 0 )&& (self.passwordField.text.length != 0) && (groupID.length > 0)) {
        if (self.flag == 1 && self.uploaded == 1 ) {
            
            [self.signUpConn signUpWithName:self.nameField.text mobile:self.mobileField.text password:self.passwordField.text groupID:(NSString *)self.selectedGroup[@"id"] imageURL:self.imageURL];
//            [self signUp];
            
        }else if (self.flag == 1){

            [self showAlertWithMsg:@"من فضلك انتظر حتي يتم رفع الصورة" alertTag:0];
        }else {
            
            [self showAlertWithMsg:@"من فضلك تأكد من اختيار صورة شخصيه او رمزيه" alertTag:0];
        }
        
    } else{

        [self showAlertWithMsg:@"من فضلك تأكد من تكمله جميع البيانات" alertTag:0];
    }


    
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



