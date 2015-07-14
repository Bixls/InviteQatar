//
//  MyProfileViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 3,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "MyProfileViewController.h"
#import "ASIHTTPRequest.h"
#import "EditAccountViewController.h"

@interface MyProfileViewController ()

@property (nonatomic) NSInteger userID;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSDictionary *user;

@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton;

    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    
    if ([self.userDefaults integerForKey:@"Guest"] != 1) {
        [self.btnActivateAccount setHidden:YES];
        [self.imgActivateAccount setHidden:YES];
    }else{
        [self.myGroup setHidden:YES];
        [self.btnAllEvents setEnabled:NO];
        [self.btnEditAccount setEnabled:NO];
        [self.btnNewEvent setEnabled:NO];
    }
    //NSLog(@"%ld",self.userID);
    if (self.userID) {
        [self getUser];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    if (self.userID) {
        [self getUser];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editProfile"]) {
        EditAccountViewController *editAccount = segue.destinationViewController;
        editAccount.userName = self.user[@"name"];
        editAccount.userPic = self.myProfilePicture.image;
    }
}

#pragma mark - Connection Setup

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
    NSDictionary *receivedDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    NSLog(@"%@",receivedDict);
    if ([key isEqualToString:@"getUser"]) {
        self.user = receivedDict;
        [self updateUI];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

-(void)updateUI {
    self.myName.text = self.user[@"name"];
    self.myGroup.text = self.user[@"GName"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.user[@"ProfilePic"]];
        NSURL *imgURL = [NSURL URLWithString:imgURLString];
        NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
        UIImage *image = [[UIImage alloc]initWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myProfilePicture.image = image;
        });
    });
}

- (IBAction)btnSignoutPressed:(id)sender {
    [self.userDefaults setInteger:0 forKey:@"Guest"];
    [self.userDefaults setInteger:0 forKey:@"signedIn"];
    [self.userDefaults setInteger:0 forKey:@"userID"];
    [self.userDefaults setInteger:0 forKey:@"Visitor"];
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"welcome" sender:self];
}



@end
