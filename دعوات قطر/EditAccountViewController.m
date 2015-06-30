//
//  EditAccountViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "EditAccountViewController.h"
#import "ASIHTTPRequest.h"

@interface EditAccountViewController ()

@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSString *maskInbox;
@property (nonatomic,strong) NSString *name;

- (IBAction)btnChecklistPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *editNameField;
- (IBAction)btnSavePressed:(id)sender;

@end

@implementation EditAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.maskInbox = [self.userDefaults objectForKey:@"maskInbox"];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.editNameField resignFirstResponder];
    self.name = self.editNameField.text;
    return YES;
}

#pragma mark - Connection setup

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
    NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil]);
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

#pragma mark - Buttons

- (IBAction)btnChecklistPressed:(id)sender {
    
    NSMutableString *maskInbox = [[NSMutableString alloc]init];
    
    if (self.maskInbox) {
        maskInbox = [NSMutableString stringWithString:self.maskInbox];
    }else{
        maskInbox = [NSMutableString stringWithString:@"00000"];
        
    }
   
    
    if ([sender tag] == 0) {
        
        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:0]];
        NSInteger value = [c integerValue];
        NSInteger notValue = !value;
        [maskInbox replaceCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
        self.maskInbox = maskInbox;
        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
        [self.userDefaults synchronize];
        NSLog(@"%@",maskInbox);
        

    }else if ([sender tag] == 1){
        
        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:1]];
        NSInteger value = [c integerValue];
        NSInteger notValue = !value;
        [maskInbox replaceCharactersInRange:NSMakeRange(1, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
        self.maskInbox = maskInbox;
        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
        [self.userDefaults synchronize];
        NSLog(@"%@",maskInbox);

        
    }else if ([sender tag] == 2){
        
        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:2]];
        NSInteger value = [c integerValue];
        NSInteger notValue = !value;
        [maskInbox replaceCharactersInRange:NSMakeRange(2, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
        self.maskInbox = maskInbox;
        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
        [self.userDefaults synchronize];
        NSLog(@"%@",maskInbox);

        
    }else if ([sender tag] == 3){
        
        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:3]];
        NSInteger value = [c integerValue];
        NSInteger notValue = !value;
        [maskInbox replaceCharactersInRange:NSMakeRange(3, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
        self.maskInbox = maskInbox;
        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
        [self.userDefaults synchronize];
        NSLog(@"%@",maskInbox);

        
    }else if ([sender tag] == 4){

        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:4]];
        NSInteger value = [c integerValue];
        NSInteger notValue = !value;
        [maskInbox replaceCharactersInRange:NSMakeRange(4, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
        self.maskInbox = maskInbox;
        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
        [self.userDefaults synchronize];
        NSLog(@"%@",maskInbox);

        
    }
        
    
}

- (IBAction)btnSavePressed:(id)sender {
    NSDictionary *postDict = @{@"FunctionName":@"editProfile" , @"inputs":@[@{@"id":@"6",@"name":self.name,
                                                                         @"maskInbox":self.maskInbox}]};
    [self postRequest:postDict];
    
}
@end
