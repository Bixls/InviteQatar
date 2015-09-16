//
//  InviteViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "InviteViewController.h"
#import "ASIHTTPRequest.h"
#import "InviteTableViewCell.h"
#import "SendMessageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface InviteViewController ()

@property (nonatomic,strong) NSArray *users;
@property (nonatomic) int flag;
@property (nonatomic,strong) NSMutableArray *selectedUsers;
@property (nonatomic,strong) NSMutableArray *usersIDs;
@property (nonatomic,strong) NSMutableArray *UsersToInvite;
@property (nonatomic,strong) NSMutableArray *selectedRows;
@property (nonatomic,strong) NSMutableArray *deletedRows;
@property (nonatomic) NSInteger groupID;
@property (nonatomic) NSInteger returnedGroupID;
@property (nonatomic) NSInteger deletionFlag;
@property (nonatomic) NSInteger VIPPoints;
@property (nonatomic) NSInteger userID;
@property (nonatomic,strong) NSString *userMobile;
@property (nonatomic,strong) NSString *userPassword;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
;
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    self.VIPPoints = [self.userDefaults integerForKey:@"VIPPoints"];
    if (self.normORVIP == 1) {
        self.VIPPoints = self.VIPPoints - 1 ; //1 VIP point for event Creation
    }
    self.groupID = [self.group[@"id"]integerValue];
    
    self.selectedUsers = [[NSMutableArray alloc]init];
    self.UsersToInvite = [[NSMutableArray alloc]init];
    self.selectedRows = [[NSMutableArray alloc]init];
    self.deletedRows = [[NSMutableArray alloc]init];
    self.usersIDs = [[NSMutableArray alloc]init];

    NSLog(@"%ld",(long)self.createMsgFlag);
    
}

-(void)viewDidAppear:(BOOL)animated{
//    if (self.normORVIP == 0) {
//        [self getUSerVIPPoints];
//    }else{
    [self.tableView reloadData];
    
    NSDictionary *getUSersDict = @{@"FunctionName":@"getUsersbyGroup" ,
                                       @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",self.groupID],
                                                     @"start":@"0",
                                                     @"limit":@"50000"}]};
        NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
        [self postRequest:getUSersDict withTag:getUsersTag];
    
//        [self getUSerVIPPoints];
//    }
    
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

#pragma mark - Segue
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([segue.identifier isEqualToString:@"createMsg"]) {
//        for (NSDictionary *user in self.selectedUsers) {
//            NSLog(@"%@",self.selectedUsers);
//            NSInteger userID = [user[@"id"]integerValue];
//            NSDictionary *dict = @{@"id":[NSNumber numberWithInteger:userID]};
//            [self.usersIDs addObject:dict];
//            NSLog(@"%@",self.usersIDs);
//        }
//        SendMessageViewController *sendMessageController = segue.destinationViewController;
//        sendMessageController.usersIDs = self.usersIDs;
//        sendMessageController.createMsgFlag = 1;
//    }
//}

#pragma mark - Table view Data Source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.users.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    InviteTableViewCell *cell = (InviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell==nil) {
        cell=[[InviteTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
   
    NSDictionary *tempDict = self.users[indexPath.row];
    cell.userName.text = tempDict[@"name"];
    

    NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempDict[@"ProfilePic"]];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    [cell.userPic sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                spinner.center = cell.userPic.center;
        spinner.hidesWhenStopped = YES;
        [cell addSubview:spinner];
        [spinner startAnimating];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.userPic.image = image;
        [spinner stopAnimating];
        NSLog(@"Cache Type %ld",(long)cacheType);
    }];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.checkmark.text = @"\u2001";
    
//    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    for(NSIndexPath *i in self.selectedRows)
    {
        NSLog(@"%@",i);
        NSLog(@"%@",indexPath);
        if([i isEqual:indexPath])
        {
            cell.checkmark.text = @"\u2713";
        }
    }
    
    return cell ;
}

#pragma mark - Table view Delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    InviteTableViewCell *cell = (InviteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.VIPPoints >= self.selectedUsers.count) {
        if ([cell.checkmark.text isEqualToString:@"\u2713"]) {
            //cell.checkmark.text = @"\u2001";
            if (self.selectedUsers.count >0) {
                [self.selectedUsers removeObject:self.users[indexPath.row]];
                [self.selectedRows removeObject:indexPath];
                
            }
            [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة" forState:UIControlStateNormal];
            self.flag = 0;
        }else{
            //cell.checkmark.text = @"\u2713";
            [self.selectedUsers addObject:self.users[indexPath.row]];
            [self.selectedRows addObject:indexPath];
        }
        [self.tableView reloadData];
    }else if (self.VIPPoints < self.selectedUsers.count){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً"
                                                           message:@"كافية VIP لا يمكنك إختيار المزيد من أفراد القبيلة لعدم توافر نقاط "
                                                          delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }

    
}

#pragma mark - Connection setup

//-(void)getUSerVIPPoints {
//    NSDictionary *getInvNum = @{
//                                @"FunctionName":@"signIn" ,
//                                @"inputs":@[@{@"Mobile":self.userMobile,
//                                              @"password":self.userPassword}]};
//    NSLog(@"%@",getInvNum);
//    
//    NSMutableDictionary *getInvNumTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"invNum",@"key", nil];
//    [self postRequest:getInvNum withTag:getInvNumTag];
//    
//}


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
    }else if ([key isEqualToString:@"invNum"]){
        
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        self.VIPPoints  = [dict[@"inVIP"]integerValue];

    }else if ([key isEqualToString:@"inviteUsers"]){

        NSDictionary *failure = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if ([failure[@"noPoints"]boolValue] == true) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"لم يتم إرسال الدعوات بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"تم إرسال الدعوات بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

-(void)getAllUsers{
    NSDictionary *getUSersDict = @{@"FunctionName":@"getUsersbyGroup" ,
                                   @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                 @"start":@"0",
                                                 @"limit":@"50000"}]};
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
    [self postRequest:getUSersDict withTag:getUsersTag];
}

- (IBAction)btnMarkAllPressed:(id)sender {
    
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        NSUInteger ints[2] = {0,i};
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
        //NSLog(@"%ld",(long)indexPath.row);
        InviteTableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        if (self.deletionFlag == 1) {
//            self.deletionFlag = 1;
//            if(self.flag == 1){
////                cell.checkmark.text = @"\u2001";
//                if (self.selectedUsers.count >0) {
//                    
//                    [self.selectedUsers removeObject:self.users[indexPath.row]];
//                    [self.selectedRows removeObject:indexPath];
//                    [self.deletedRows addObject:indexPath];
//                    if (self.deletedRows.count == self.users.count) {
//                        self.deletionFlag =0;
//                        [self.deletedRows removeAllObjects];
//                    }
//                }
//            }
//            
//            
//        }else if (self.flag==1){
//            //do nothing
//        }else{
////            cell.checkmark.text = @"\u2713";
//            [self.selectedUsers addObject:self.users[indexPath.row]];
//            [self.selectedRows addObject:indexPath];
//            self.deletionFlag =0;
//            if (self.selectedUsers.count == self.users.count) {
//                self.deletionFlag = 1;
//            }
//        }
    }
    self.flag = !(self.flag);
    if (self.flag == 1) {
        [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة \u2713" forState:UIControlStateNormal];
        [self.selectedUsers removeAllObjects];
        [self.selectedUsers addObjectsFromArray:self.users];
        for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
            NSUInteger ints[2] = {0,i};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
            [self.selectedRows addObject:indexPath];
        }
    }else{
        [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة" forState:UIControlStateNormal];
        [self.selectedUsers removeAllObjects];
        [self.selectedRows removeAllObjects];
    }
    
    NSLog(@"%ld",(long)self.flag);
    [self.tableView reloadData];
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)btnInvitePressed:(id)sender {
    
    if (self.selectedUsers.count >0 && self.createMsgFlag != 1) {
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
        
    }else if (self.createMsgFlag == 1){
        [self performSegueWithIdentifier:@"createMsg" sender:self];
    }

}

- (IBAction)btnBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
