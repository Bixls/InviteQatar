//
//  SendMessageViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 12,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SendMessageViewController.h"
#import "ASIHTTPRequest.h"
@interface SendMessageViewController ()
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@end

@implementation SendMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
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


//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    [textField resignFirstResponder];
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView Delegate Methods

//-(void)textViewDidBeginEditing:(UITextView *)textView {
//    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"تم" style:UIBarButtonItemStyleDone target:self action:@selector(removeKeyboard)];
//
//    [self.navigationItem setRightBarButtonItem:doneBtn];
//}

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


#pragma mark - Connection Setup

-(void)sendMessage {
    
    NSDictionary *sendMessage = @{@"FunctionName":@"sendMessege" , @"inputs":@[@{
                                                                                 @"SenderID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                 @"ReciverID":[NSString stringWithFormat:@"%ld",(long)self.receiverID],
                                                                                 @"Subject":self.messageSubject.text,
                                                                                 @"Content":self.messageContent.text
                                                                                 }]};
    
    NSLog(@"%@",sendMessage);
    NSMutableDictionary *sendMessageTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"sendMessage",@"key", nil];
    
    [self postRequest:sendMessage withTag:sendMessageTag];
    
}

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
    
    //NSString *responseString = [request responseString];
    
    NSData *responseData = [request responseData];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    if ([key isEqualToString:@"sendMessage"]) {
        NSLog(@"%@ DICTIONARY ", dictionary);
        NSInteger success = [dictionary[@"success"]integerValue];
        if (success == 0) {
            UIAlertView * alerView = [[UIAlertView alloc]initWithTitle:@"" message:@"تم إرسال الرسالة بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alerView show];
        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)btnSendPressed:(id)sender {
    if (self.messageContent.text.length >0 && self.messageSubject.text.length > 0) {
        [self sendMessage];
    }else{
        UIAlertView * alerView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"من فضلك تأكد من إدخال عنوان و محتوي للرسالة" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alerView show];
    }
    
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
