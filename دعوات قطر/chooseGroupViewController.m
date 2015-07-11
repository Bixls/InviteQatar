//
//  chooseGroupViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "chooseGroupViewController.h"
#import "ASIHTTPRequest.h"
#import "ChooseGroupTableViewCell.h"

@interface chooseGroupViewController ()

@property (nonatomic , strong) NSArray *responseArray;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@end

@implementation chooseGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *postDict = @{
                               @"FunctionName":@"getGroupList" ,
                               @"inputs":@[@{@"limit":[NSNumber numberWithInt:1000]}]};
    [self postRequest:postDict];
    
}

#pragma mark - Table view Data Source Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *tempArray = [self.userDefaults objectForKey:@"groupArray"];
    return tempArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    ChooseGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[ChooseGroupTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *tempArray = [self.userDefaults objectForKey:@"groupArray"];
    NSLog(@"%@",tempArray);
    cell.groupName.text = tempArray[indexPath.row][@"name"];
    NSLog(@"%@",cell.groupName.text);
    return cell ;
}

#pragma mark - Table view Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectedGroup = self.responseArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(selectedGroup:)]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.delegate selectedGroup:selectedGroup];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    
     //Use when fetching text data
    NSString *responseString = [request responseString];
    // Use when fetching binary data
    
    NSData *responseData = [request responseData];
    self.responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSLog(@"%@", self.responseArray );
    if ([self.responseArray isEqualToArray:[self.userDefaults objectForKey:@"groupArray"]]) {
        //do nothing
    }else{
        [self.userDefaults setObject:self.responseArray forKey:@"groupArray"];
        [self.userDefaults synchronize];
        [self.tableView reloadData];
    }
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}


- (IBAction)btnDismissPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
