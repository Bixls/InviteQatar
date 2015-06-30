//
//  GroupViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 30,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "GroupViewController.h"
#import "ASIHTTPRequest.h"
#import <UIKit/UIKit.h>

@interface GroupViewController ()

@property (nonatomic,strong) NSArray *users;
@property (nonatomic) int flag;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flag = 0;
    NSDictionary *postDict = @{@"FunctionName":@"getUsersbyGroup" , @"inputs":@[@{@"groupID":@"2",@"start":@"0",@"limit":@"50000"}]};
    
 
    [self postRequest:postDict];
    
}

#pragma mark - Table view Data Source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.users.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *tempDict = self.users[indexPath.row];
    cell.detailTextLabel.text = tempDict[@"name"];
    
    return cell ;
}

#pragma mark - Table view Delegate methods 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"\u2713"]) {
        cell.textLabel.text = @"\u2001";
    }else{
        cell.textLabel.text = @"\u2713";
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    self.users = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    [self.tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



- (IBAction)btnMarkAllPressed:(id)sender {
    
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        NSUInteger ints[2] = {0,i};
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell.textLabel.text isEqualToString:@"\u2713"]) {
            if(self.flag == 1){
                cell.textLabel.text = @"\u2001";
            }
        }else if (self.flag==1){
            //do nothing
        }else{
            cell.textLabel.text = @"\u2713";
        }
    }
    self.flag = !(self.flag);
    if (self.flag == 1) {
        [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة \u2713" forState:UIControlStateNormal];
    }else{
        [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة \u2001" forState:UIControlStateNormal];
    }
    
    NSLog(@"%ld",(long)self.flag);
    [self.tableView reloadData];
}
@end
