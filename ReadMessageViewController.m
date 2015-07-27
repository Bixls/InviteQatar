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
    NSLog(@"%@",self.message);
    self.view.backgroundColor = [UIColor blackColor];
    self.labelName.text = self.userName;
    self.labelSubject.text = self.messageSubject;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%ld",(long)self.profilePicNumber];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *img = [[UIImage alloc]initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.imgUser.image = img;
            
        });
    });
    
    if (self.messageType == 1) {
        [self.imgUser setHidden:YES];
        [self.labelDate setHidden:YES];
        [self.labelName setHidden:YES];

    }else if (self.messageType == 0){
        [self.imgUser setHidden:NO];
        [self.labelDate setHidden:NO];
        [self.labelName setHidden:NO];

    }
    [self.navigationItem setHidesBackButton:YES];

}

-(void)viewDidAppear:(BOOL)animated{
        [self readMessage];
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

#pragma mark - Connection Setup

-(void)readMessage {
    
    NSDictionary *readMessage = @{@"FunctionName":@"ReadMessege" , @"inputs":@[@{
                                                                                   @"messageID":[NSString stringWithFormat:@"%ld",(long)self.messageID]
                                                                                 }]};
   
    if (self.messageType == 0 || self.messageType == 1) {
        NSMutableDictionary *readMessageTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"readMessage",@"key", nil];
        [self postRequest:readMessage withTag:readMessageTag];
        
    }else if (self.messageType == 2 || self.messageType == 3){
        NSMutableDictionary *readMessageTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"readInvitation",@"key", nil];
        [self postRequest:readMessage withTag:readMessageTag];
        
    }

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
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    if ([key isEqualToString:@"readMessage"]) {

        NSDictionary *dict = arr[0];
        NSLog(@"%@",dict);
        self.message = dict;
        self.textViewMessage.text = self.message[@"Content"];
        self.labelDate.text = self.message[@"TimeSent"];
    }else if ([key isEqualToString:@"readInvitation"]){
        NSDictionary *dict = arr[0];
        NSLog(@"%@",dict);
        self.message = dict;
        self.textViewMessage.text = self.message[@"Content"];
        self.labelDate.text = self.message[@"TimeSent"];
        self.labelSubject.text = self.message[@"subject"];
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


- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}




//- (IBAction)btnSendMessagePressed:(id)sender {
//}
@end
