//
//  ConfirmationViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "ASIHTTPRequest.h"
#import "NetworkConnection.h"
#import "WelcomeUserViewController.h"

@interface ConfirmationViewController ()

@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) int savedID;
@property (nonatomic) NSInteger activateFlag;

@property (weak, nonatomic) IBOutlet UIImageView *responseImage;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;
@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet customAlertView *customAlert;

@property (strong,nonatomic)NSDictionary *responseDictionary;
@property (strong,nonatomic)NSDictionary *user;
@property (nonatomic,strong) NetworkConnection *verifyConn;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) NSInteger imageID;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.activateFlag = [self.userDefaults integerForKey:@"activateFlag"];

    //NSLog(@"Self.user id = %ld",(long)self.userID);
    self.verifyConn = [[NetworkConnection alloc]init];
    [self.customAlertView setHidden:YES];
    self.customAlert.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self.verifyConn addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.verifyConn removeObserver:self forKeyPath:@"response"];
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

#pragma mark - Custom Alert

-(void)customAlertCancelBtnPressed{
    [self.customAlertView setHidden:YES];
    if (self.customAlert.tag == 1) {
        [self performSegueWithIdentifier:@"welcomeUser" sender:self];
    }
}

#pragma mark - KVO Methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"response"]) {
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//        NSLog(@"%@",self.responseDictionary);
        if ([self.responseDictionary[@"success"]boolValue] == false) {
            
            [self.customAlert showAlertWithMsg:@"عفواً كود التفعيل خطأ" alertTag:0 customAlertView:self.customAlertView customAlert:self.customAlert];
        }else if ([self.responseDictionary[@"success"]boolValue] == true){
            self.user = self.responseDictionary[@"data"];
            [self.customAlert showAlertWithMsg:@"شكراً لك تم تفعيل حسابك" alertTag:1 customAlertView:self.customAlertView customAlert:self.customAlert];
//            NSLog(@"%@",self.responseDictionary);
            [self.userDefaults setInteger:0 forKey:@"Guest"];
            [self.userDefaults setInteger:1 forKey:@"signedIn"];
            [self.userDefaults synchronize];
            self.activateFlag = 0;
            [self.userDefaults setInteger:self.activateFlag forKey:@"activateFlag"];

            
        }
//        NSLog(@"%@",self.responseDictionary);
        
        
    }
}
#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"welcomeUser"]) {
        WelcomeUserViewController *welcomeUserController = segue.destinationViewController;
        welcomeUserController.userName = self.user[@"name"];
        welcomeUserController.groupName = self.user[@"Gname"];
        welcomeUserController.imageID = [self.user[@"ProfilePic"]integerValue];

    }
}

#pragma mark Textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    NSLog(@"%@",self.confirmField.text);
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Buttons 

- (IBAction)btnConfirmPressed:(id)sender {
    NSDictionary *postDict = @{@"FunctionName":@"Verify" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                                                                                                              @"Verified":self.confirmField.text}]};
    [self.verifyConn postRequest:postDict withTag:nil];
    
//    [self postRequest:postDict];
}

- (IBAction)btnDismiss:(id)sender {
    [self.confirmField resignFirstResponder];
}

- (IBAction)btnBackPressed:(id)sender {
    if (self.activateFlag == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.activateFlag == 1){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

@end
