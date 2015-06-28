//
//  ConfirmationViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ConfirmationViewController.h"

@interface ConfirmationViewController ()

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%@",self.confirmField.text);
    [textField resignFirstResponder];
    return YES;
}


-(void)confirm{
    NSDictionary *postDict = @{@"key":@"-1", @"FunctionName":@"Verify" , @"inputs":@[@{@"id":@"8",
                                                                                       @"Verified":self.confirmField.text}]};
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

- (IBAction)btnConfirmPressed:(id)sender {
    [self confirm];
}
@end
