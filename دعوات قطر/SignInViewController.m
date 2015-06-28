//
//  SignInViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%@ , %@",self.usernameField.text , self.passwordField.text);
    [textField resignFirstResponder];
    return YES;
}


-(void)signIn{
    NSDictionary *postDict = @{@"key":@"-1", @"FunctionName":@"signIn" , @"inputs":@[@{@"username":self.usernameField.text,
                                                                                       @"password":self.passwordField.text}]};
    NSLog(@"%@",postDict);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = @"http://bixls.com/Qatar/" ;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"POST" ;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *receivedDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",receivedDictionary);
    }];
    
    [task resume];
    
}

- (IBAction)btnSignInPressed:(id)sender {
    [self signIn];
}
@end
