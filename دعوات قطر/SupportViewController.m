//
//  SupportViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 11,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SupportViewController.h"
#import "ASIHTTPRequest.h"
@interface SupportViewController ()

@property (nonatomic) NSInteger userID ;
@property (nonatomic) NSInteger feedbackType ;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@end

@implementation SupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationItem setHidesBackButton:YES];
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
#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView Delegate Methods

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

#pragma mark - Action Sheet Delegate Methods
- (void)actionSheet:(UIActionSheet * )actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.btnChooseType setTitle:@"شكوي" forState:UIControlStateNormal];
        self.feedbackType = 0;
        
    }
    else if(buttonIndex == 1){
         [self.btnChooseType setTitle:@"إقتراح" forState:UIControlStateNormal];
        self.feedbackType = 1;
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

- (void)requestFinished:(ASIHTTPRequest *)request
{

    NSString *responseString = [request responseString];
    
    NSData *responseData = [request responseData];
    NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"sendFeedback"]) {
        NSLog(@"%@",responseDict);
        NSInteger success = [responseDict[@"success"]integerValue];
        NSLog(@"%ld",(long)success);
        if (success == 0) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"شكراً" message:@"تم إرسال الرساله بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];

        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



#pragma mark - Buttons
- (IBAction)btnChooseTypePressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"نوع الرساله" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"شكوي",@"إقتراح", nil];
    [actionSheet showInView:self.view];
}
- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnSendPressed:(id)sender {
    if (self.nameField.text.length > 0 && self.msgField.text.length > 0 && (self.feedbackType == 0 || self.feedbackType==1) ) {
        NSDictionary *sendFeedback = @{@"FunctionName":@"SendFeedback" , @"inputs":@[@{
                                                                                         @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                         @"FeedbackType":[NSString stringWithFormat:@"%ld",(long)self.feedbackType],
                                                                                         @"Subject":self.nameField.text,
                                                                                         @"Message":self.msgField.text
                                                                                         }]};
        NSMutableDictionary *sendFeedbackTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"sendFeedback",@"key", nil];
        [self postRequest:sendFeedback withTag:sendFeedbackTag];

    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من استكمال جميع البيانات" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }
    

}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
