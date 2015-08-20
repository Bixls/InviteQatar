//
//  ConfirmationViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "ASIHTTPRequest.h"


@interface ConfirmationViewController ()

@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) int savedID;

@property (weak, nonatomic) IBOutlet UIImageView *responseImage;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (strong,nonatomic)NSDictionary *responseDictionary;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    [self.navigationItem setHidesBackButton:YES];
    NSLog(@"Self.user id = %d",self.userID);

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
    NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    self.responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    if ([self.responseDictionary[@"success"] integerValue] == 0) {
        self.responseLabel.text = @"عفوا كودالتفعيل خطأ" ;
    }else if ([self.responseDictionary[@"success"] integerValue]== 1){
        self.responseLabel.text = @"شكراً لك تم تفعيل حسابك";
        [self.userDefaults setInteger:0 forKey:@"Guest"];
        [self.userDefaults setInteger:1 forKey:@"signedIn"];
        [self.userDefaults synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    NSLog(@"%@",self.responseDictionary);
 
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}




#pragma mark Textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%@",self.confirmField.text);
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Buttons 

- (IBAction)btnConfirmPressed:(id)sender {
    NSDictionary *postDict = @{@"FunctionName":@"Verify" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%d",self.userID],
                                                                                                                                                                              @"Verified":self.confirmField.text}]};
    
    [self postRequest:postDict];
}

- (IBAction)btnDismiss:(id)sender {
    [self.confirmField resignFirstResponder];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
