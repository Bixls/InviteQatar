//
//  InviteViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "InviteViewController.h"
#import "ASIHTTPRequest.h"

@interface InviteViewController ()

@property (nonatomic,strong) NSArray *users;
@property (nonatomic) int flag;
@property (nonatomic,strong) NSMutableArray *selectedUsers;
@property (nonatomic,strong) NSMutableArray *UsersToInvite;
@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedUsers = [[NSMutableArray alloc]init];
    self.UsersToInvite = [[NSMutableArray alloc]init];
    [self getUSer];
    
    
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
        if (self.selectedUsers.count >0) {
            [self.selectedUsers removeObject:self.users[indexPath.row]];
        }
    }else{
        cell.textLabel.text = @"\u2713";
        [self.selectedUsers addObject:self.users[indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Connection setup

-(void)getUSer {
    
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{
                                                                               @"id":[NSString stringWithFormat:@"%ld",(long)self.creatorID]
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
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"getUsers"]) {
        self.users = array;
        NSLog(@"%@",self.users);
        [self.tableView reloadData];
    }else if ([key isEqualToString:@"getUser"]){
        NSLog(@"%@",array);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSInteger groupID =[dict[@"Gid"]integerValue];
        
        NSDictionary *getUSersDict = @{@"FunctionName":@"getUsersbyGroup" ,
                                       @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",groupID],
                                                     @"start":@"0",
                                                     @"limit":@"50000"}]};
        NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
        [self postRequest:getUSersDict withTag:getUsersTag];
    }else if ([key isEqualToString:@"inviteUsers"]){
        NSLog(@"%@",array);
        NSDictionary *dict = array[0];
        NSInteger success = [dict[@"success"]integerValue];
        NSLog(@"%ld",success);
        if (success == 0) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"تم إرسال الدعوة بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    
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
                if (self.selectedUsers.count >0) {
                    [self.selectedUsers removeObject:self.users[indexPath.row]];
                }
            }
        }else if (self.flag==1){
            //do nothing
        }else{
            cell.textLabel.text = @"\u2713";
            [self.selectedUsers addObject:self.users[indexPath.row]];
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

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)btnInvitePressed:(id)sender {
    if (self.selectedUsers.count >0) {
        for (int i =0; i < self.selectedUsers.count; i++) {
            
            NSDictionary *dict = self.selectedUsers[i];
            NSInteger userID = [dict[@"id"]integerValue];
            NSDictionary *temp = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)userID],@"id", nil];
            [self.UsersToInvite addObject:temp];
            
        }
        
        NSDictionary *inviteUsers = @{@"FunctionName":@"invite" ,
                                      @"inputs":@[@{@"EventID":[NSString stringWithFormat:@"%ld",self.eventID],
                                                    @"listArray":self.UsersToInvite,
                                                    }]};
        NSMutableDictionary *inviteUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"inviteUsers",@"key", nil];
        [self postRequest:inviteUsers withTag:inviteUsersTag];
        
    }

}
@end
