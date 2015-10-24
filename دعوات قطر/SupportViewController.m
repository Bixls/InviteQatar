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
@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet customAlertView *customAlert;
@property (strong, nonatomic) UIActivityIndicatorView *sendingFeedBack;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;

@end

@implementation SupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.view.backgroundColor = [UIColor blackColor];
    [self.customAlertView setHidden:YES];
    self.customAlert.delegate = self;
    self.viewHeight.constant = self.view.bounds.size.height - 35;
    self.feedbackType = -1;
    [self.navigationItem setHidesBackButton:YES];
    [self addOrRemoveFooter];
}

-(void)addOrRemoveFooter {
    BOOL remove = [[self.userDefaults objectForKey:@"removeFooter"]boolValue];
    [self removeFooter:remove];
    
}

-(void)removeFooter:(BOOL)remove{
    self.footerContainer.clipsToBounds = YES;
    if (remove == YES) {
        self.footerHeight.constant = 0;
    }else if (remove == NO){
        self.footerHeight.constant = 492;
    }
    [self.userDefaults setObject:[NSNumber numberWithBool:remove] forKey:@"removeFooter"];
    [self.userDefaults synchronize];
}

-(void)viewDidAppear:(BOOL)animated{
    if ([self.userDefaults objectForKey:@"userName"] != nil) {
        self.nameField.text = [self.userDefaults objectForKey:@"userName"];
        [self getUser];
    }else{
        [self getUser];
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
//        NSLog(@"Return pressed");
        [textView resignFirstResponder];
    } else {
//        NSLog(@"Other pressed");
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

#pragma mark - Custom ALert 
-(void)customAlertCancelBtnPressed{
    [self.customAlertView setHidden:YES];
    if (self.customAlert.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)showAlertWithMsg:(NSString *)msg alertTag:(NSInteger )tag {
    
    [self.customAlertView setHidden:NO];
    self.customAlert.viewLabel.text = msg ;
    self.customAlert.tag = tag;
    
}
#pragma mark - Connection setup

-(void)getUser {
    
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                             }]};
    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
    
    [self postRequest:getUser withTag:getUserTag];
    
}

-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict{
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    NSString *urlString = @"http://da3wat-qatar.com/api/" ;
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
        NSInteger success = [responseDict[@"success"]integerValue];

        if (success == 0) {
//            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"شكراً" message:@"تم إرسال الرساله بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
//            [alertView show];

//            [self showAlertWithMsg:@"تم إرسال الرساله بنجاح" alertTag:1];
            self.customAlert.viewLabel.text = @"تم إرسال الرساله بنجاح" ;
            self.customAlert.tag = 1;
            [self.customAlert.closeButton setHidden:NO];
            [self.btnSendFeedback setEnabled:YES];
            [self.sendingFeedBack stopAnimating];
        }else{

//            [self showAlertWithMsg:@"عفواً حاول مرة أخري" alertTag:0];
            self.customAlert.viewLabel.text = @"عفواً حاول مرة اخري" ;
            self.customAlert.tag = 0;
            [self.customAlert.closeButton setHidden:NO];
            [self.btnSendFeedback setEnabled:YES];
            [self.sendingFeedBack stopAnimating];
        }
    } else if ([key isEqualToString:@"getUser"]) {

        if ([responseDict[@"name"] isEqualToString:[self.userDefaults objectForKey:@"userName"]]) {
            //
        }else{
            self.nameField.text = responseDict[@"name"] ;
            [self.userDefaults setObject:responseDict[@"name"] forKey:@"userName"];
            [self.userDefaults synchronize];
        }
        
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self.sendingFeedBack stopAnimating];
    self.customAlert.viewLabel.text = @"عفواً حاول مرة أخري" ;
    [self.customAlert.closeButton setHidden:NO];
    [self.btnSendFeedback setEnabled:YES];
    
    NSError *error = [request error];
//    NSLog(@"%@",error);
}

#pragma mark - Segue 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Buttons
- (IBAction)btnChooseTypePressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"نوع الرساله" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"شكوي",@"إقتراح", nil];
    [actionSheet showInView:self.view];
}


- (IBAction)btnSendPressed:(id)sender {
    if (self.nameField.text.length > 0 && self.msgField.text.length > 0 && (self.feedbackType == 0 || self.feedbackType==1) ) {
        NSDictionary *sendFeedback = @{@"FunctionName":@"SendFeedback" , @"inputs":@[@{
                                                                                         @"SenderID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                         @"FeedbackType":[NSString stringWithFormat:@"%ld",(long)self.feedbackType],
                                                                                         @"Subject":self.nameField.text,
                                                                                         @"Message":self.msgField.text
                                                                                         }]};
        NSMutableDictionary *sendFeedbackTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"sendFeedback",@"key", nil];
        
        
        self.customAlert.viewLabel.text = @"من فضلك إنتظر حتي يتم إنشاء الدعوة" ;
        [self.customAlertView setHidden:NO];
        [self.customAlert.closeButton setHidden:YES];
        [self.btnSendFeedback setEnabled:NO];
        
        self.sendingFeedBack= [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.sendingFeedBack.hidesWhenStopped = YES;
        self.sendingFeedBack.center = CGPointMake(self.customAlertView.frame.size.width/2, self.customAlert.frame.origin.y - 40);
        [self.customAlertView addSubview:self.sendingFeedBack];
        [self.sendingFeedBack startAnimating];
        
        [self postRequest:sendFeedback withTag:sendFeedbackTag];

    }else{
        self.customAlert.viewLabel.text = @"من فضلك تأكد من استكمال جميع البيانات";
        [self.customAlertView setHidden:NO];

//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
//        [self.btnSendFeedback setEnabled:YES];
//        [alertView show];
    }
    

}
- (IBAction)btnCallNumPressed:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:+97450003609"]];
}



@end
