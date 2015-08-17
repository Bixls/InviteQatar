//
//  MyProfileViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 3,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "MyProfileViewController.h"
#import "ASIHTTPRequest.h"
#import "EditAccountViewController.h"
#import "EventViewController.h"

@interface MyProfileViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;

@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger groupID;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic,strong) NSString *userMobile;
@property (nonatomic,strong) NSString *userPassword;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton;
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    
    if ([self.userDefaults integerForKey:@"Guest"] != 1) {
        [self.btnActivateAccount setHidden:YES];
        [self.imgActivateAccount setHidden:YES];
    }else{
        [self.myGroup setHidden:YES];
        [self.btnAllEvents setEnabled:NO];
        [self.btnEditAccount setEnabled:NO];
        [self.btnNewEvent setEnabled:NO];
    }
  
    //NSLog(@"%ld",self.userID);
//    if (self.userID) {
//        [self getUser];
//    }
    [self.navigationItem setHidesBackButton:YES];
    [self.activateLabel setHidden:YES];
    [self.activateLabel2 setHidden:YES];
    
    if ([self.userDefaults integerForKey:@"Guest"]==1) {
        [self.tableView setHidden:YES];
        [self.btnSeeMore setHidden:YES];
        [self.imgSeeMore setHidden:YES];
        self.smallerView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
        [self.activateLabel setHidden:NO];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    if (self.userID) {
        [self getUser];
    }
    if (self.userMobile && self.userPassword) {
        NSDictionary *getInvNum = @{
                                    @"FunctionName":@"signIn" ,
                                    @"inputs":@[@{@"Mobile":self.userMobile,
                                                  @"password":self.userPassword}]};
        NSLog(@"%@",getInvNum);
        
        
        NSMutableDictionary *getInvNumTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"invNum",@"key", nil];
        [self postRequest:getInvNum withTag:getInvNumTag];
        
    }
    NSDictionary *getEvents = @{@"FunctionName":@"getUserEventsList" , @"inputs":@[@{@"userID":[NSString stringWithFormat:@"%ld",(long)self.userID],@"start":[NSString stringWithFormat:@"%d",0],@"limit":[NSString stringWithFormat:@"%d",3]
                                                                                     }]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
    [self postRequest:getEvents withTag:getEventsTag];
    

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

#pragma mark - Table View


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.events.count > 0) {
        [self.btnSeeMore setHidden:NO];
        [self.imgSeeMore setHidden:NO];
        [self.activateLabel setHidden:YES];
        [self.activateLabel2 setHidden:YES];
        return self.events.count ;
    }else{
        
        [self.btnSeeMore setHidden:YES];
        [self.imgSeeMore setHidden:YES];
        [self.activateLabel setHidden:NO];
        [self.activateLabel2 setHidden:NO];
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    if (indexPath.row < self.events.count) {
        
        MyLatestEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[MyLatestEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *tempEvent = self.events[indexPath.row];
        cell.eventName.text =tempEvent[@"subject"];
        cell.eventCreator.text = tempEvent[@"CreatorName"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
        [formatter setLocale:qatarLocale];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",tempEvent[@"TimeEnded"]]];
        NSString *date = [formatter stringFromDate:dateString];
        NSString *dateWithoutSeconds = [date substringToIndex:16];
        cell.eventDate.text = dateWithoutSeconds;
        NSLog(@"%@",date);
        //cell.eventDate.text = tempEvent[@"TimeEnded"];
        
        if ([[tempEvent objectForKey:@"VIP"]integerValue] == 0) {
            [cell.vipImage setHidden:YES];
            [cell.vipLabel setHidden:YES];
        }else{
            [cell.vipImage setHidden:NO];
            [cell.vipLabel setHidden:NO];
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempEvent[@"EventPic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.eventPic.image = image;
            });
            
        });
        
        self.tableVerticalLayoutConstraint.constant = self.tableView.contentSize.height;
        return cell ;
    }
//    else if (indexPath.row == self.events.count){
//        MyLatestEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"seeMore" forIndexPath:indexPath];
//        if (cell==nil) {
//            cell=[[MyLatestEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;
//    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.events.count) {
        self.selectedEvent = self.events[indexPath.row];
        [self performSegueWithIdentifier:@"event" sender:self];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editProfile"]) {
        EditAccountViewController *editAccount = segue.destinationViewController;
        editAccount.userName = self.user[@"name"];
        editAccount.userPic = self.myProfilePicture.image;
        editAccount.groupID = [self.user[@"Gid"]integerValue];
        editAccount.groupName = self.user[@"GName"];
        NSLog(@"%@",self.user[@"GName"]);
        
    }else if ([segue.identifier isEqualToString:@"event"]) {
        
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
        
    }
}

#pragma mark - Connection Setup

-(void)getUser {
   
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)self.userID],
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
    
    //NSString *responseString = [request responseString];
    
    NSData *responseData = [request responseData];
    NSDictionary *receivedDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    NSLog(@"%@",receivedDict);
    if ([key isEqualToString:@"getUser"]) {
        self.user = receivedDict;
        [self updateUI];
   
    }else if ([key isEqualToString:@"invNum"]){
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        NSString *normal = dict[@"inNOR"];
        NSString *VIP  = dict[@"inVIP"];
        [self.btnInvitationNum setTitle:normal forState:UIControlStateNormal];
        [self.btnVIPNum setTitle:VIP forState:UIControlStateNormal];
        [self.userDefaults setInteger:[VIP integerValue] forKey:@"VIPPoints"];
        [self.userDefaults synchronize];

    }else if ([key isEqualToString:@"getEvents"]){
        NSArray *responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.events = responseArray;
        [self.tableView reloadData];

    }

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

-(void)updateUI {
    self.myName.text = self.user[@"name"];
    self.myGroup.text = self.user[@"GName"];
   // self.groupID = [self.user[@"Gid"]integerValue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.user[@"ProfilePic"]];
        NSURL *imgURL = [NSURL URLWithString:imgURLString];
        NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
        UIImage *image = [[UIImage alloc]initWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myProfilePicture.image = image;
        });
    });
}

- (IBAction)btnSignoutPressed:(id)sender {
    [self.userDefaults setInteger:0 forKey:@"Guest"];
    [self.userDefaults setInteger:0 forKey:@"signedIn"];
    [self.userDefaults setInteger:0 forKey:@"userID"];
    [self.userDefaults setInteger:0 forKey:@"Visitor"];
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"welcome" sender:self];
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSeeMorePressed:(id)sender {
    [self performSegueWithIdentifier:@"seeMore" sender:self];
}


@end
