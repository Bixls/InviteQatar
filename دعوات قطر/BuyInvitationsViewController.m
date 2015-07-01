//
//  BuyInvitationsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 1,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "BuyInvitationsViewController.h"
#import "ConnectionAdapter.h"
#import "ASIHTTPRequest.h"

@interface BuyInvitationsViewController ()

@property(nonatomic,strong) ConnectionAdapter *connection;
@property(nonatomic,strong) NSDictionary *postDict;
@property(nonatomic,strong) NSArray *responseArray;

@end

@implementation BuyInvitationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postDict = @{
                      @"FunctionName":@"getInvitationList" ,
                      @"inputs":@[@{@"limit":@"10"}]};
    
    [self postRequest:self.postDict];
    
}



#pragma mark - Connection Setup

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
    //NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    self.responseArray = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSLog(@"%@",self.responseArray);
    
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}


@end
