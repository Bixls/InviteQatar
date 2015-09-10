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

@interface SignInViewController ()

@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger savedID;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic,strong) NetworkConnection *connection;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationItem setHidesBackButton:YES];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.savedID = [self.userDefaults integerForKey:@"userID"];
    
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
        //
        
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil]);
        self.user = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSString *temp = [NSString stringWithFormat:@"%@",self.user[@"Mobile"]];
        NSInteger userID = [self.user[@"id"]integerValue];
        NSInteger guest = ![self.user[@"Verified"]integerValue];
        NSString * mobile = self.mobileField.text;
        NSString * password = self.passwordField.text;
        NSLog(@"%ld",(long)guest);
        if ([temp isEqualToString:self.mobileField.text]) {
            [self.userDefaults setInteger:1 forKey:@"signedIn"];
            [self.userDefaults setInteger:guest forKey:@"Guest"];
            [self.userDefaults setObject:self.user forKey:@"user"];
            [self.userDefaults setInteger:userID forKey:@"userID"];
            [self.userDefaults setObject:mobile forKey:@"mobile"];
            [self.userDefaults setObject:password forKey:@"password"];
            [self.userDefaults synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من إدخال بياناتك الصحيحة" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }

    }
}

#pragma mark - Textfield delegate methods 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%@ , %@",self.passwordField.text , self.passwordField.text);
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Buttons

- (IBAction)btnSignInPressed:(id)sender {
    
    
    
    NSDictionary *postDict = @{
                               @"FunctionName":@"signIn" ,
                               @"inputs":@[@{@"Mobile":self.mobileField.text,
                                                                                       @"password":self.passwordField.text}]};
    //[self postRequest:postDict];
    [self.connection postRequest:postDict withTag:nil];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
