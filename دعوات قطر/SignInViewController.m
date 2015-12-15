//
//  SignInViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SignInViewController.h"
#import "ASIHTTPRequest.h"
#import "NetworkConnection.h"
#import "WelcomeUserViewController.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet customAlertView *customAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnForgetMyPass;



@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger savedID;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic,strong) NetworkConnection *connection;
@property (nonatomic,strong) NetworkConnection *forgetPasswordConn;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic) NSInteger imageID;


@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.customAlertView setHidden:YES];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.savedID = [self.userDefaults integerForKey:@"userID"];
    self.customAlert.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{

    [self initiateSignIn];
    [self initiateForgetPassword];
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

-(void)initiateSignIn{
    
    self.connection = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        
        self.user = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        if ([self.user[@"Verified"]integerValue] == 1) {
            [self.userDefaults setInteger:1 forKey:@"signedIn"];
            [self.userDefaults synchronize];
            self.userName = self.user[@"name"];
            self.groupName = self.user[@"Gname"];
            self.imageID = [self.user[@"ProfilePic"]integerValue];
            [self saveUserData];
            [self performSegueWithIdentifier:@"welcomeUser" sender:self];
            
        }else if (self.user[@"success"]!= nil && [self.user[@"success"]boolValue] == false ){
            
            [self showAlertWithMsg:@"من فضلك تأكد من إدخال بياناتك الصحيحة" alertTag:0];
            
        }else if ([self.user[@"Verified"]integerValue] != 1 && self.user[@"Verified"] != nil ){
            [self saveUserData];
            [self performSegueWithIdentifier:@"activate" sender:self];
        }else if (self.user == nil){
            [self showAlertWithMsg:@"هناك خطأ في الإتصال من فضلك حاول مرة أخري" alertTag:0];
        }

        
    }];
}

-(void)initiateForgetPassword{
    self.forgetPasswordConn = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        NSLog(@"%@",responseDict);
        if ([responseDict[@"sucess"]boolValue] == true) {
            [self showAlertWithMsg:@"تم ارسال رسالة نصية بها كلمة السر الخاصة بك" alertTag:0];
        }else{
            [self showAlertWithMsg:@"لم يتم العثور على حساب بهذا الرقم" alertTag:0];
        }
    }];
}

#pragma mark - Custom Alert

-(void)showAlertWithMsg:(NSString *)msg alertTag:(NSInteger )tag {
    
    [self.customAlertView setHidden:NO];
    self.customAlert.viewLabel.text = msg ;
    self.customAlert.tag = tag;
}

-(void)customAlertCancelBtnPressed{
    [self.customAlertView setHidden:YES];
}


#pragma mark - Methods

-(void)saveUserData {
 
    [self.userDefaults setObject:self.user forKey:@"user"];
    [self.userDefaults setInteger:[self.user[@"id"]integerValue] forKey:@"userID"];
    [self.userDefaults setInteger:[self.user[@"Mobile"]integerValue] forKey:@"mobile"];
    [self.userDefaults setObject:self.userName forKey:@"userName"];
    [self.userDefaults setObject:self.groupName forKey:@"groupName"];

    [self.userDefaults setObject:self.password forKey:@"password"];
    [self.userDefaults synchronize];

}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"welcomeUser"]) {
        WelcomeUserViewController *welcomeUserController = segue.destinationViewController;
        welcomeUserController.userName = self.userName;
        welcomeUserController.imageID = self.imageID;
        welcomeUserController.groupName = self.groupName;
        //add group name
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }
}

#pragma mark - Textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Header Delegate

-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Buttons

- (IBAction)btnSignInPressed:(id)sender {
    
    
    self.password = self.passwordField.text;
    
    NSDictionary *postDict = @{
                               @"FunctionName":@"signIn" ,
                               @"inputs":@[@{@"Mobile":self.mobileField.text,
                                                                                       @"password":self.passwordField.text}]};
    [self.connection postRequest:postDict withTag:nil];
}

- (IBAction)btnForgetMyPassPressed:(id)sender {
    if (self.mobileField.text.length == 0) {
         [self showAlertWithMsg:@"من فضلك أدخل رقم الهاتف" alertTag:0];
    }else{
        [self.forgetPasswordConn forgetMyPassword:self.mobileField.text];
    }
}

@end
