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
#import "CreateEventViewController.h"
#import "EventViewController.h"
@interface InviteViewController ()

@property (nonatomic,strong) NSArray *users;
@property (nonatomic) int flag;
@property (nonatomic,strong) NSMutableArray *selectedUsers;
@property (nonatomic,strong) NSMutableArray *usersIDs;
@property (nonatomic,strong) NSMutableArray *UsersToInvite;
@property (nonatomic,strong) NSMutableArray *selectedRows;
@property (nonatomic,strong) NSMutableArray *deletedRows;
@property (nonatomic,strong) NSMutableDictionary *choosenUsers;
@property (nonatomic) NSInteger groupID;
@property (nonatomic) NSInteger returnedGroupID;
@property (nonatomic) NSInteger deletionFlag;
@property (nonatomic) NSInteger VIPPoints;
@property (nonatomic) NSInteger userID;
@property (nonatomic) BOOL firstTime;
@property (nonatomic,strong) NSString *userMobile;
@property (nonatomic,strong) NSString *userPassword;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property(nonatomic,strong)NSMutableArray *inviteesMutable;
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
//        self.VIPPoints = self.VIPPoints - 1 ; //1 VIP point for event Creation
    }else if (self.normORVIP == 0){
        [self.VIPNumberLabel removeFromSuperview];
        [self.VIPlbl removeFromSuperview];
    }
    self.groupID = [self.group[@"id"]integerValue];
    self.firstTime = YES;
    
    self.inviteesMutable = [[NSMutableArray alloc]initWithArray:self.invitees];
    if (self.inviteesMutable.count > 0) {
        self.selectedUsers = [[NSMutableArray alloc]initWithArray:self.invitees];

//        NSLog(@"%@",self.selectedUsers);
    }else{
        self.selectedUsers = [[NSMutableArray alloc]init];
    }
    self.UsersToInvite = [[NSMutableArray alloc]init];
    self.selectedRows = [[NSMutableArray alloc]init];
    self.deletedRows = [[NSMutableArray alloc]init];
    self.usersIDs = [[NSMutableArray alloc]init];
    self.choosenUsers = [[NSMutableDictionary alloc]init];
//    NSLog(@"%ld",(long)self.createMsgFlag);
    [self updateInvitesStatus];
    
}

-(void)updateInvitesStatus{
    
    self.inviteesNumberLabel.text = [self arabicNumberFromEnglish:self.selectedUsers.count];
    self.VIPNumberLabel.text = [self arabicNumberFromEnglish:self.VIPPoints];
    
    if (self.selectedUsers.count <= 0) {
        self.inviteesNumberLabel.textColor = [UIColor redColor];
    }else{
         self.inviteesNumberLabel.textColor = [UIColor orangeColor];
    }
    if (self.VIPPoints <= 0) {
        self.VIPNumberLabel.textColor = [UIColor redColor];
    }else{
         self.VIPNumberLabel.textColor = [UIColor orangeColor];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{

    if (self.editingMode == YES) {
        [self getUnInvitedUsers];
    }else{
        NSDictionary *getUSersDict = @{@"FunctionName":@"getUsersbyGroup" ,
                                       @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                     @"start":@"0",
                                                     @"limit":@"50000"}]};
        NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
        [self postRequest:getUSersDict withTag:getUsersTag];
    }

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

-(NSString *)arabicNumberFromEnglish:(NSInteger)num {
    NSNumber *someNumber = [NSNumber numberWithInteger:num];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ar"];
    [formatter setLocale:gbLocale];
    return [formatter stringFromNumber:someNumber];
}




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
//    NSLog(@"%@",self.users);
    NSDictionary *tempDict = self.users[indexPath.row];
    cell.userName.text = tempDict[@"name"];
    

    NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempDict[@"ProfilePic"]];
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
//        NSLog(@"Cache Type %ld",(long)cacheType);
    }];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.checkmark.text = @"\u2001";
    
//    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    if (self.inviteesMutable.count > 0 && self.firstTime == YES) {
            for (NSDictionary *invitee in self.inviteesMutable) {
                NSInteger inviteeID = [invitee[@"id"]integerValue];
                
                if (inviteeID == [tempDict[@"id"]integerValue]) {
                    cell.checkmark.text = @"\u2713";
                    [self.selectedRows addObject:indexPath];
//                    NSLog(@"Marked !! ");
                    break;
                }
            }
   
    }
    
    for(NSIndexPath *i in self.selectedRows)
    {
//        NSLog(@"%@",i);
//        NSLog(@"%@",indexPath);
        if([i isEqual:indexPath])
        {
            cell.checkmark.text = @"\u2713";
        }
    }
    
    return cell ;
}
-(void)searchAndDeleteItemWithKey:(NSDictionary *)user{
    NSInteger userKey = [user[@"id"]integerValue];
    for (int i = 0 ; i < self.inviteesMutable.count ; i++) {
        NSDictionary *tempDictionary = self.inviteesMutable[i];
         NSInteger key = [tempDictionary[@"id"]integerValue];
        if (key == userKey) {
            [self.inviteesMutable removeObject:tempDictionary];
        }
    }
}
#pragma mark - Table view Delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    self.invitees = nil;
    self.firstTime = NO;
    InviteTableViewCell *cell = (InviteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.VIPPoints != 0 && self.normORVIP == 1) {
//        NSLog(@"%ld",(long)self.VIPPoints);
        
        if ([cell.checkmark.text isEqualToString:@"\u2713"]) {
            if (self.selectedUsers.count >0) {
                [self.selectedUsers removeObject:self.users[indexPath.row]];
                [self.selectedRows removeObject:indexPath];
//                [self searchAndDeleteItemWithKey:self.users[indexPath.row]];
                self.VIPPoints += 1;
            }
            [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة" forState:UIControlStateNormal];
            self.flag = 0;
        }else{
            //cell.checkmark.text = @"\u2713";
            [self.selectedUsers addObject:self.users[indexPath.row]];
            [self.selectedRows addObject:indexPath];
            self.VIPPoints -= 1;

//            NSLog(@"%lu",(unsigned long)self.selectedUsers.count);
        }
        [self updateInvitesStatus];
        [self.tableView reloadData];
        
    }else if (self.VIPPoints == 0 && self.normORVIP == 1){
        
        if ([cell.checkmark.text isEqualToString:@"\u2713"]) {
            if (self.selectedUsers.count >0) {
                [self.selectedUsers removeObject:self.users[indexPath.row]];
                [self.selectedRows removeObject:indexPath];
//                [self searchAndDeleteItemWithKey:self.users[indexPath.row]];
                self.VIPPoints +=1;
  
            }
            [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة" forState:UIControlStateNormal];
            self.flag = 0;
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً"
                                                               message:@" لا يمكنك إختيار المزيد من أفراد القبيلة لعدم توافر نقاط VIP كافية "
                                                              delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        [self updateInvitesStatus];
        [self.tableView reloadData];
        
    }else if (self.normORVIP == 0){
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
            
//            NSLog(@"%lu",(unsigned long)self.selectedUsers.count);
        }
        [self updateInvitesStatus];
        [self.tableView reloadData];
    }

    
}

#pragma mark - Connection setup

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
//    NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"getUsers"]) {
        self.users = array;
        [self.tableView reloadData];
    }else if ([key isEqualToString:@"invNum"]){
        
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//        NSLog(@"%@",dict);
        self.VIPPoints  = [dict[@"inVIP"]integerValue];

    }else if ([key isEqualToString:@"sendInvites"]){

        NSDictionary *failure = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if ([failure[@"noPoints"]boolValue] == true) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"لم يتم إرسال الدعوات بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            if (self.editingMode == YES) {
                [self jumpToRootViewController];
            }else{
                [self jumpToEventViewController];
            }
        }
    }else if ([key isEqualToString:@"getUninvited"]){
        self.users = array;
        [self.tableView reloadData];
    }
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
//    NSLog(@"%@",error);
}



-(void)getAllUsers{
    NSDictionary *getUSersDict = @{@"FunctionName":@"getUsersbyGroup" ,
                                   @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                 @"start":@"0",
                                                 @"limit":@"50000"}]};
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
    [self postRequest:getUSersDict withTag:getUsersTag];
}

-(void)getUnInvitedUsers{
    NSDictionary *getUSersDict = @{@"FunctionName":@"getInvited" ,
                                   @"inputs":@[@{@"groupID":[NSNumber numberWithInteger:self.groupID],
                                                 @"start":@"0",
                                                 @"limit":@"50000",
                                                 @"invitation_status":[NSNumber numberWithInteger:1],
                                                 @"EventID":[NSNumber numberWithInteger:self.eventID]
                                                 }]};
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUninvited",@"key", nil];
    [self postRequest:getUSersDict withTag:getUsersTag];
    
}

-(void)sendInvitationsWithArray:(NSMutableArray *)users {
    NSDictionary *getUSersDict = @{@"FunctionName":@"invite" ,
                                   @"inputs":@[@{@"EventID":[NSString stringWithFormat:@"%ld",(long)self.eventID],
                                                 @"listArray":users,
                                                 }]};
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"sendInvites",@"key", nil];
    [self postRequest:getUSersDict withTag:getUsersTag];
    
}

- (IBAction)btnMarkAllPressed:(id)sender {
    
//    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
//        NSUInteger ints[2] = {0,i};
//        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
//
//    }
    
    self.flag = !(self.flag);
    if (self.flag == 1) {
        [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة \u2713" forState:UIControlStateNormal];
        if (self.normORVIP == 1) {
            self.VIPPoints = self.VIPPoints + self.selectedUsers.count;
            [self.selectedUsers removeAllObjects];
            [self.selectedRows removeAllObjects];
            [self updateInvitesStatus];
        }else{
            [self.selectedUsers removeAllObjects];
            [self.selectedRows removeAllObjects];
        }

//        [self.selectedUsers addObjectsFromArray:self.users];
        if (self.normORVIP == 1){
            for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
            
                NSUInteger ints[2] = {0,i};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
//                NSLog(@"Selected users Count %lu",(unsigned long)self.selectedUsers.count);
//                NSLog(@"VIP Points Count %ld" , (long)self.VIPPoints);
                if (self.VIPPoints != 0) {
//                    [self.selectedUsers addObjectsFromArray:self.users[indexPath.row]];
                    [self.selectedUsers addObject:self.users[indexPath.row]];
                    [self.selectedRows addObject:indexPath];
                    self.VIPPoints -= 1 ;
                    [self updateInvitesStatus];
                }else{
//                    NSLog(@"%@",self.selectedUsers);
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"لا يمكن إضافة أشخاص أخري لعدم توافر دعوات VIP كافية" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
                    [alertView show];
                    [self updateInvitesStatus];
                    break;
                }
            }
        }else if (self.normORVIP == 0){
            for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++){
                NSUInteger ints[2] = {0,i};
                NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
//                [self.selectedUsers addObjectsFromArray:self.users[indexPath.row]];
                [self.selectedUsers addObject:self.users[indexPath.row]];
                [self.selectedRows addObject:indexPath];
                [self updateInvitesStatus];
            }
        }else{
//            NSLog(@"%@",self.selectedUsers);
            [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة" forState:UIControlStateNormal];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"لا يمكن إضافة أشخاص أخري لعدم توافر دعوات VIP كافية" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
            [self updateInvitesStatus];
        }
        
    }else{
        [self.btnMarkAll setTitle:@"دعوة لكافة القبيلة" forState:UIControlStateNormal];
        if (self.normORVIP == 1) {
            self.VIPPoints = self.VIPPoints + self.selectedUsers.count;
        }
        [self.selectedUsers removeAllObjects];
        [self.selectedRows removeAllObjects];
        [self updateInvitesStatus];
    }
    
//    NSLog(@"%ld",(long)self.flag);
    [self.tableView reloadData];
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.userDefaults setInteger:self.VIPPoints forKey:@"VIPPoints"];
    [self.userDefaults synchronize];
}

- (IBAction)btnInvitePressed:(id)sender {
    self.choosenUsers = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.normORVIP],@"type",self.selectedUsers,@"data",nil];
//    NSLog(@"%@",self.choosenUsers);
    [self.userDefaults setObject:self.choosenUsers forKey:@"invitees"];
    [self.userDefaults setInteger:self.VIPPoints forKey:@"VIPPoints"];
    [self.userDefaults synchronize];
    
    if (self.editingMode) {
        for (int i =0; i < self.selectedUsers.count; i++) {
            
            NSDictionary *dict = self.selectedUsers[i];
            NSInteger userID = [dict[@"id"]integerValue];
            NSDictionary *temp = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)userID],@"id", nil];
            [self.UsersToInvite addObject:temp];
        }
        [self sendInvitationsWithArray:self.UsersToInvite];

    }else{
        [self jumpToRootViewController];
    }
    
}


- (IBAction)btnBackPressed:(id)sender {
    [self.userDefaults setInteger:self.VIPPoints forKey:@"VIPPoints"];
    [self.userDefaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)jumpToRootViewController {
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        
        //This if condition checks whether the viewController's class is MyGroupViewController
        // if true that means its the MyGroupViewController (which has been pushed at some point)
        if ([viewController isKindOfClass:[CreateEventViewController class]] ) {
            
            // Here viewController is a reference of UIViewController base class of MyGroupViewController
            // but viewController holds MyGroupViewController  object so we can type cast it here
            CreateEventViewController *createEventController = (CreateEventViewController*)viewController;
            [self.navigationController popToViewController:createEventController animated:YES];
        }
    }
}
-(void)jumpToEventViewController {
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        
        //This if condition checks whether the viewController's class is MyGroupViewController
        // if true that means its the MyGroupViewController (which has been pushed at some point)
        if ([viewController isKindOfClass:[EventViewController class]] ) {
            
            // Here viewController is a reference of UIViewController base class of MyGroupViewController
            // but viewController holds MyGroupViewController  object so we can type cast it here
            EventViewController *eventController = (EventViewController*)viewController;
            [self.navigationController popToViewController:eventController animated:YES];
        }
    }
}
@end


/* Invite 
 
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
 
 */

