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

@interface ConfirmationViewController ()

@property (strong,nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) int savedID;
@property (nonatomic) NSInteger activateFlag;

@property (weak, nonatomic) IBOutlet UIImageView *responseImage;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;

@property (strong,nonatomic)NSDictionary *responseDictionary;
@property (nonatomic,strong) NetworkConnection *verifyConn;

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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"response"]) {
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        
        if ([self.responseDictionary[@"success"]boolValue] == false) {
            self.responseLabel.text = @"عفواً كود التفعيل خطأ" ;
        }else if ([self.responseDictionary[@"success"]boolValue] == true){
            self.responseLabel.text = @"شكراً لك تم تفعيل حسابك";
            [self.userDefaults setInteger:0 forKey:@"Guest"];
            [self.userDefaults setInteger:1 forKey:@"signedIn"];
            [self.userDefaults synchronize];
            self.activateFlag = 0;
            [self.userDefaults setInteger:self.activateFlag forKey:@"activateFlag"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        NSLog(@"%@",self.responseDictionary);
        
        
    }
}


#pragma mark Textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%@",self.confirmField.text);
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
