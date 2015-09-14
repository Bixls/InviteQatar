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

@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger savedID;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic,strong) NetworkConnection *connection;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) NSInteger imageID;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //[self.navigationItem setHidesBackButton:YES];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.savedID = [self.userDefaults integerForKey:@"userID"];
    

    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    self.connection = [[NetworkConnection alloc]init];
    [self.connection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.connection removeObserver:self forKeyPath:@"response"];
    
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
    if ([keyPath isEqualToString:@"response"]) {
        
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.user = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        

        NSInteger userID = [self.user[@"id"]integerValue];
        NSInteger mobile =[self.user[@"Mobile"]integerValue];
        
        
        //NSInteger guest = ![self.user[@"Verified"]integerValue];
        
//        NSString * password = self.passwordField.text;
        //NSLog(@"%ld",(long)guest);
        
        //[temp isEqualToString:self.mobileField.text]
        

        if ([self.user[@"Verified"]boolValue] == true) {
            [self.userDefaults setInteger:1 forKey:@"signedIn"];
            [self.userDefaults synchronize];
            [self saveUserData];
            self.userName = self.user[@"name"];
//            self.groupName = self.user[@"GName"]; //check key first
            self.imageID = [self.user[@"ProfilePic"]integerValue];
            
            [self performSegueWithIdentifier:@"welcomeUser" sender:self];
            //[self dismissViewControllerAnimated:YES completion:nil];
            
        }else if (self.user[@"success"]!= nil && [self.user[@"success"]boolValue] == false ){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من إدخال بياناتك الصحيحة" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }else if ([self.user[@"Verified"]boolValue] == false){
            [self saveUserData];
            [self performSegueWithIdentifier:@"activate" sender:self];
        }

    }
}

#pragma mark - Methods

-(void)saveUserData {
    NSInteger userID = [self.user[@"id"]integerValue];
    NSInteger userMobile =[self.user[@"Mobile"]integerValue];
    NSString *userName = self.user[@"name"];
    
    [self.userDefaults setObject:self.user forKey:@"user"];
    [self.userDefaults setInteger:userID forKey:@"userID"];
    [self.userDefaults setInteger:userMobile forKey:@"mobile"];
    [self.userDefaults setObject:userName forKey:@"userName"];
    
    [self.userDefaults synchronize];

}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"welcomeUser"]) {
        WelcomeUserViewController *welcomeUserController = segue.destinationViewController;
        welcomeUserController.userName = self.userName;
        welcomeUserController.imageID = self.imageID;
        //add group name
    }
}

#pragma mark - Textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
