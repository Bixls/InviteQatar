//
//  SignInViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SignInViewController.h"
#import "ASIHTTPRequest.h"

@interface SignInViewController ()

@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger savedID;
@property (nonatomic,strong) NSDictionary *user;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
//    if (self.userID) {
//        [self.userDefaults setInteger:self.userID forKey:@"userID"];
//    }
    self.savedID = [self.userDefaults integerForKey:@"userID"];
    
    
}

-(void)postRequest:(NSDictionary *)postDict{
    
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
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    [request startAsynchronous];
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    NSData *responseData = [request responseData];
    NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil]);
    self.user = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *temp = [NSString stringWithFormat:@"%@",self.user[@"Mobile"]];
    NSInteger userID = [self.user[@"id"]integerValue];
    NSInteger guest = ![self.user[@"Verified"]integerValue];
    NSLog(@"%ld",(long)guest);
    if ([temp isEqualToString:self.mobileField.text]) {
        [self.userDefaults setInteger:1 forKey:@"signedIn"];
        [self.userDefaults setInteger:guest forKey:@"Guest"];
        [self.userDefaults setObject:self.user forKey:@"user"];
        [self.userDefaults setInteger:userID forKey:@"userID"];
        [self.userDefaults synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
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
    [self postRequest:postDict];
}



@end
