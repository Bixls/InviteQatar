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
#import "CellInvitationTableView.h"

@interface BuyInvitationsViewController ()

@property(nonatomic,strong) ConnectionAdapter *connection;
@property(nonatomic,strong) NSDictionary *postDict;
@property(nonatomic,strong) NSArray *responseArray;
@property(nonatomic,strong) NSDictionary *selectedItem;
@property(nonatomic,strong) NSArray *tableArray;
@property(nonatomic) NSInteger flag;

@end

@implementation BuyInvitationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flag =0 ;
    self.postDict = @{
                      @"FunctionName":@"getInvitationList" ,
                      @"inputs":@[@{@"limit":@"10"}]};
    
    [self postRequest:self.postDict];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    CellInvitationTableView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[CellInvitationTableView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.flag == 0) {
        NSDictionary *tempDict = self.tableArray[indexPath.row];
        cell.label0.text = [NSString stringWithFormat:@"$ %@",tempDict[@"price"]];
        cell.label1.text = tempDict[@"packageName"];
        cell.label2.text = tempDict[@"number"];
        
        return cell ;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedItem = self.responseArray[indexPath.row];
    self.flag =1;
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
    if (self.flag == 0) {
         self.tableArray = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    }
    self.responseArray = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSLog(@"%@",self.responseArray);
    
    [self.tableView reloadData];
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



- (IBAction)btnBuyNowPressed:(id)sender {
    int id = [self.selectedItem[@"id"]integerValue] ;
    self.postDict = @{
                      @"FunctionName":@"addInvPoints" ,
                      @"inputs":@[@{@"memberID":@"3",@"invitationID":[NSNumber numberWithInt:id]}]};
    if (self.flag==1) {
        [self postRequest:self.postDict];
    }
    
}
@end
