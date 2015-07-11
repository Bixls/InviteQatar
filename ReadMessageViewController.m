//
//  ReadMessageViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ReadMessageViewController.h"
#import "ASIHTTPRequest.h"

@interface ReadMessageViewController ()

@property(nonatomic,strong)NSDictionary *message;

@end

@implementation ReadMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self readMessage];
}


#pragma mark - Connection Setup

-(void)readMessage {
    
    NSDictionary *readMessage = @{@"FunctionName":@"ReadMessege" , @"inputs":@[@{
                                                                                   @"messageID":[NSString stringWithFormat:@"%ld",(long)self.messageID]
                                                                                 }]};
    NSMutableDictionary *readMessageTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"readMessage",@"key", nil];
    [self postRequest:readMessage withTag:readMessageTag];
    
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
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"readMessage"]) {
        NSLog(@"%@",dict);
        self.message = dict;
    }
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



@end
